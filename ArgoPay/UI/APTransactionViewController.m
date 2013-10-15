//
//  APTransactionViewController.m
//  ArgoPay
//
//  Created by victor on 10/15/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APHomeViewController.h"
#import "VSNavigationViewController.h"
#import "APTransaction.h"

#import "ZBarSDK.h"
#import "APDebug.h"
#import "APStrings.h"
#import "APPopup.h"
#import "APLocation.h"
#import "APAccount.h"
#import "APRemoteStrings.h"

/**
 *  Wrapper for ZBar VC which has a bug (missing auto release)
 *
 * Discussion here:
 *
 * http://sourceforge.net/p/zbar/discussion/1072195/thread/df4c215a/
 *
 */
@interface APCamera : ZBarReaderViewController<ZBarReaderDelegate>
@property (nonatomic,strong) NSString *resultText;
@property (nonatomic,strong) UIImage * resultImage;
@end

@implementation APCamera
APLOGRELEASE
- (void) loadView
{
    self.view = [[UIView alloc]
                 initWithFrame: CGRectMake(0, 0, 320, 480)];
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.wantsFullScreenLayout = NO;
    self.readerDelegate = self;
    [self.scanner setSymbology: 0
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    [self.scanner setSymbology: ZBAR_QRCODE
                          config: ZBAR_CFG_ENABLE
                              to: 1];
    self.readerView.zoom = 0.8;
    
}

-(BOOL)navigationBarHidden
{
    return YES;
}

-(BOOL)underTabBar
{
    return YES;
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol * sym = nil;
    for( sym in results) break;
    self.resultImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    self.resultText = sym.data;
    APLOG(kDebugScan, @"Got scan result %@", self.resultText);
    [self setLastTransitionType:kVSTransitionNoAnimation];
    [self performSegueWithIdentifier:kSegueCameraUnwind sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
}

@end

/**
 *  Modal screen that waits for transaction status
 */
@interface APTranasctionBillViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *grandTotal;
@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *merchantCategory;

@property (nonatomic,strong) NSString * scanResultText;
@property (nonatomic,strong) NSString * transID;
@property (nonatomic,strong) APTransactionStatusResponse *statusResponse;

@end

@implementation APTranasctionBillViewController

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _grandTotal.text = nil;
    _merchantName.text = nil;
    _merchantCategory.text = nil;
    
    _cancelButton.layer.masksToBounds = YES;
    _cancelButton.layer.cornerRadius = 8.0;
}

-(void)setScanResultText:(NSString *)scanResultText
{
    _scanResultText = scanResultText;
    [self attemptTransaction];
}

-(void)setStatusResponse:(APTransactionStatusResponse *)statusResponse
{
    _statusResponse = statusResponse;
    _grandTotal.text = [NSString stringWithFormat:@"%.2f",[_statusResponse.TotalAmount floatValue]];
    _merchantName.text = _statusResponse.MerchName;
    _merchantCategory.text = _statusResponse.Category;
}

-(void)handleTransaction:(APPopup *)popup transID:(NSString *)transID
{
    APRemoteAPIRequestBlock handleStatusReponse = ^(APTransactionStatusResponse *response, NSError *err)
    {
        APTranasctionBillViewController *vc = self;
        if( err )
        {
            [popup dismiss];
            [vc showError:err];
        }
        else
        {
            NSString *stat = response.TransStatus;
            
            if( [stat isEqualToString:kRemoteValueTransactionStatusPending] )
            {
                [NSObject performBlock:^{
                    [self handleTransaction:popup transID:transID];
                } afterDelay:0.5];
                return;
            }
            
            [popup dismiss];
            
            if( [stat isEqualToString:kRemoteValueTransactionStatusInsufficientFunds] )
            {
                [APPopup msgWithParent:vc.view text:NSLocalizedString(@"Sorry, there are insufficient funds in your ArgoPay Account to cover this purchase!", @"TransactionResponse")];
            }
            else if( [stat isEqualToString:kRemoteValueTransactionStatusServerCancelled] )
            {
                [APPopup msgWithParent:vc.view text:NSLocalizedString(@"This transaction was cancelled!", @"TransactionResponse")];
            }
            else if( [stat isEqualToString:kRemoteValueTransactionStatusTimeOut] )
            {
                [APPopup msgWithParent:vc.view text:NSLocalizedString(@"This transaction was cancelled because it was taking too long.", @"TransactionResponse")];
            }
            else if( [stat isEqualToString:kRemoteValueTransactionStatusReadyForApproval] )
            {
                vc.statusResponse = response;
            }
        }
    };
    
    APRequestTransactionStatus *request = [APRequestTransactionStatus new];
    request.TransID = transID;
    APAccount * account = [APAccount currentAccount];
    request.AToken = account.AToken;
    [request performRequest:handleStatusReponse];
}

-(void)attemptTransaction
{
    __block APPopup *popup = [APPopup withNetActivity:self.view];
    
    APRequestTransactionStart *start = [APRequestTransactionStart new];
    [[APLocation sharedInstance] currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [self performBlock:^(id sender) {
                [popup dismiss];
                [self showError:error];
            } afterDelay:0.1];
            return NO;
        }
        else
        {
            APAccount *account = [APAccount currentAccount];
            start.AToken = account.AToken;
            start.QrData = _scanResultText;
            start.Lat = @(loc.latitude);
            start.Long = @(loc.longitude);
            [start performRequest:^(APTransactionIDResponse *idResponse, NSError *err) {
                [NSObject performBlock:^{
                    if( err )
                    {
                        [popup dismiss];
                        [self showError:err];
                    }
                    else
                    {
                        [self handleTransaction:popup transID:idResponse.TransID];
                    }
                } afterDelay:0.1];
            }];
        }
        return NO;
    }];
}

@end

/**
 *  Handles transaction cycle
 */
@interface APTransactionViewController : APHomeViewController
@property (nonatomic,strong) NSString *scanResultText;
@property (nonatomic,strong) UIImage * scanResultImage;

@end


@implementation APTransactionViewController

-(IBAction)unwindFromCamera:(UIStoryboardSegue *)segue
{
    APCamera * camera = segue.sourceViewController;
    _scanResultImage = camera.resultImage;
    _scanResultText  = camera.resultText;
    [self showTransactionBill];
}

-(void)showTransactionBill
{
    VSNavigationViewController * vc = self.vsNavigationController;
    if( vc.animating == YES )
    {
        [NSObject performBlock:^{
            NSLog(@"delaying show");
            [self showTransactionBill];
        } afterDelay:0.2];
        return;
    }
    NSLog(@"showing now");
    [self performSegueWithIdentifier:kSegueTransactionBill sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueTransactionBill] )
    {
        APTranasctionBillViewController * bill = segue.destinationViewController;
        bill.scanResultText = _scanResultText;
    }
    [super prepareForSegue:segue sender:sender];
}

-(IBAction)unWindFromBillAccept:(UIStoryboardSegue *)segue
{
    NSLog(@"Bill accepted");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)unWindFromBillCancel:(UIStoryboardSegue *)segue
{
    NSLog(@"Bill cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

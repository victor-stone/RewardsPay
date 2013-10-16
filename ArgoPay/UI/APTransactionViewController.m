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

@end

/**
 *  Modal screen that waits for use to accept/reject payment
 */
@interface APTranasctionBillViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *grandTotal;
@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *merchantCategory;

@property (nonatomic,strong) NSString * transID;
@property (nonatomic,strong) APTransactionStatusResponse *statusResponse;
@end

@implementation APTranasctionBillViewController

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cancelButton.layer.masksToBounds = YES;
    _cancelButton.layer.cornerRadius = 8.0;
}

-(void)setStatusResponse:(APTransactionStatusResponse *)statusResponse
{
    _statusResponse = statusResponse;
    [self view];
    _grandTotal.text = [NSString stringWithFormat:@"%.2f",[_statusResponse.TotalAmount floatValue]];
    _merchantName.text = _statusResponse.MerchName;
    _merchantCategory.text = _statusResponse.Category;
}

@end

/**
 *  Handles transaction cycle
 */
@interface APTransactionViewController : APHomeViewController
@end

// making these properties quiets warning messages about weak
// pointers in blocks
@interface APTransactionViewController ()
@property (nonatomic,strong) NSString *transID;
@property (nonatomic,strong) NSString *scanResultText;
@property (nonatomic,strong) UIImage * scanResultImage;
@property (nonatomic,strong) APTransactionStatusResponse *statusResponse;
@property (nonatomic,strong) APPopup *popup;
@end


@implementation APTransactionViewController

/**
 *  Camera unwind segue lands here after a QR code has been scanned
 *
 *  @param segue Source is camera, destination is self
 */
-(IBAction)unwindFromCamera:(UIStoryboardSegue *)segue
{
    APCamera * camera = segue.sourceViewController;
    _scanResultImage = camera.resultImage;
    _scanResultText  = camera.resultText;
    [self attemptTransaction];
}


/**
 *  Transaction entry point
 */
-(void)attemptTransaction
{
    self.popup = [APPopup withNetActivity:self.popupParent delay:NO];
    
    __weak APTransactionViewController * me = self;
    
    APRequestTransactionStart *start = [APRequestTransactionStart new];
    
    // Step 1. Get location
    //
    [[APLocation sharedInstance] currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [NSObject performBlock:^{
                me.popup = nil;
                [self showError:error];
            } afterDelay:0.1];
            return NO;
        }
        else
        {
            // Step 2. Request a transactionID from server
            //
            APAccount *account = [APAccount currentAccount];
            start.AToken = account.AToken;
            start.QrData = _scanResultText;
            start.Lat = @(loc.latitude);
            start.Long = @(loc.longitude);
            [start performRequest:^(APTransactionIDResponse *idResponse, NSError *err) {
                [NSObject performBlock:^{
                    if( err )
                    {
                        me.popup = nil;
                        [self showError:err];
                    }
                    else
                    {
                        me.transID = idResponse.TransID;
                        [me handleTransaction];
                    }
                } afterDelay:0.1];
            }];
        }
        return NO;
    }];
}

/**
 *  Rerty-able transaction request handler
 *
 */
-(void)handleTransaction
{
    __weak APTransactionViewController * me = self;
    
    // Step 3. Request a status on the transaction
    APRequestTransactionStatus *request = [APRequestTransactionStatus new];
    APAccount * account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.TransID = _transID;
    
    [request performRequest: ^(APTransactionStatusResponse *response, NSError *err)
    {
        if( err )
        {
            me.popup = nil;
            [me showError:err];
        }
        else
        {
            NSString *stat = response.TransStatus;
            
            if( [stat isEqualToString:kRemoteValueTransactionStatusPending] )
            {
                [NSObject performBlock:^{
                    [me handleTransaction];
                } afterDelay:0.5];
                return;
            }
            
            me.popup = nil;
            
            if( [stat isEqualToString:kRemoteValueTransactionStatusReadyForApproval] )
            {
                // Step 4. Ask the user to accept/reject
                me.statusResponse = response;
                [me performSystemSegue:kSegueTransactionBill sender:self];
            }
            else
            {
                me.popup = [APPopup msgWithParent:me.popupParent text:response.UserMessage];
            }
        }
    }];
    
}

/**
 *  Step 5. Pass along payment information to Bill view controller
 *
 *  @param segue  Source is self, destination is Bill VC
 *  @param sender (ignored)
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueTransactionBill] )
    {
        APTranasctionBillViewController * bill = segue.destinationViewController;
        bill.statusResponse = _statusResponse;
    }
    [super prepareForSegue:segue sender:sender];
}

/**
 *  Transaction Bill VC segue unwinds to here on cancel
 *
 *  @param segue Source is Bill VC, destination is self
 */
-(IBAction)unWindFromBillCancel:(UIStoryboardSegue *)segue
{
    [self userAction:kRemoteValueNO];
}

/**
 *  Transaction Bill VC segue unwinds to here on accept
 *
 *  @param segue Source is Bill VC, destination is self
 */
-(IBAction)unWindFromBillAccept:(UIStoryboardSegue *)segue
{
    [self userAction:kRemoteValueYES];
}

/**
 *  Step 6. Inform the server of the user's choice
 *
 *  @param type kRemoteValueYES for accept, kRemoteValueNO for cancel
 */
-(void)userAction:(NSString *)type
{
    __weak APTransactionViewController * me = self;
    
    [self dismissViewControllerAnimated:YES completion:^{

        me.popup = [APPopup withNetActivity:me.popupParent delay:NO];
        
        APRequestTransactionApprove *request = [APRequestTransactionApprove new];
        APAccount *account = [APAccount currentAccount];
        request.AToken = account.AToken;
        request.Approve = type;
        request.TransID = me.transID;
        
        [request performRequest:^(APRemoteRepsonse *response, NSError *err)
         {
             me.popup = nil;
             if( err )
             {
                 APLOG(kDebugScan, @"Server responded with error: %@", err);
                 [me showError:err];
             }
             else
             {
                 APLOG(kDebugScan, @"Server responsded with: %@", response);
                 [APPopup msgWithParent:me.popupParent text:response.UserMessage dismissBlock:^{
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }];
             }
         }];
    }];
}

-(void)setPopup:(APPopup *)popup
{
    if( _popup )
        [_popup dismiss];
    _popup = popup;
}

-(UIView *)popupParent
{
    return [self tabNavigator].view;
}
@end

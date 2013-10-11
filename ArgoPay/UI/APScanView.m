//
//  APScanView.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APScanView.h"
#import "APStrings.h"
#import "ZBarSDK.h"
#import "APPopup.h"
#import "APTransaction.h"
#import "APRemoteStrings.h"
#import "APTranasctionViewController.h"
#import "APLocation.h"
#import "APAccount.h"

/**
 *  Wrapper for ZBar VC which has a bug (missing auto release)
 *
 * Discussion here:
 * 
 * http://sourceforge.net/p/zbar/discussion/1072195/thread/df4c215a/
 *
 */
@interface APZBarWrapper : ZBarReaderViewController
@end
@implementation APZBarWrapper
APLOGRELEASE
- (void) loadView
{
    self.view = [[UIView alloc]
                 initWithFrame: CGRectMake(0, 0, 320, 480)];
}
@end

@implementation APScanResult
@end

@interface APScanRequestWatcher ()
@property (weak,nonatomic) id<APScanDelegate> delegate;
@end

@implementation APScanRequestWatcher {
    ZBarReaderViewController * _reader;
}

APLOGRELEASE

-(id)initWithDelegate:(id<APScanDelegate>)delegate
{
    self = [super init];
    if( !self )
        return nil;

    _delegate = delegate;
    
    [self registerForBroadcast:kNotifyTransactionUserActed
                         block:^(APScanRequestWatcher *me, APRequestTransactionApprove *request)
     {
         APLOG(kDebugScan, @"User acted, calling server with %@", request);
         [request performRequest:^(APRemoteRepsonse *response, NSError *err)
          {
              UIViewController *vc = [delegate scanHostViewController];
              if( err )
              {
                  APLOG(kDebugScan, @"Server responded with error: %@", err);
                  [vc showError:err];
              }
              else
              {
                  APLOG(kDebugScan, @"Server responsded with: %@", response);
                  [APPopup msgWithParent:vc.view text:response.UserMessage];
              }
          }];
     }];
    
    return self;
}

-(void)handleTransaction:(APPopup *)popup transID:(NSString *)transID
{
    APRemoteAPIRequestBlock handleStatusReponse = ^(APTransactionStatusResponse *response, NSError *err)
    {
        UIViewController *vc = [_delegate scanHostViewController];
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
                APTranasctionViewController * vct = [vc.storyboard instantiateViewControllerWithIdentifier:kViewTransaction];
                vct.transID = transID;
                vct.statusResponse = response;
                [NSObject performBlock:^{
                    [vc presentViewController:vct animated:YES completion:nil];
                } afterDelay:0.3];
            }
        }
    };
    
    APRequestTransactionStatus *request = [APRequestTransactionStatus new];
    request.TransID = transID;
    APAccount * account = [APAccount currentAccount];
    request.AToken = account.AToken;
    [request performRequest:handleStatusReponse];
}

-(void)attemptTransaction:(APScanResult *)result
{
    UIViewController *vc = [_delegate scanHostViewController];
    __block APPopup *popup = [APPopup withNetActivity:vc.view];
    
    APRequestTransactionStart *start = [APRequestTransactionStart new];
    [[APLocation sharedInstance] currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [self performBlock:^(id sender) {
                [popup dismiss];
                [vc showError:error];
            } afterDelay:0.1];
            return NO;
        }
        else
        {
            APAccount *account = [APAccount currentAccount];
            start.AToken = account.AToken;
            start.QrData = result.text;
            start.Lat = @(loc.latitude);
            start.Long = @(loc.longitude);
            [start performRequest:^(APTransactionIDResponse *idResponse, NSError *err) {
                [NSObject performBlock:^{
                    if( err )
                    {
                        [popup dismiss];
                        [vc showError:err];
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


-(UIViewController *)request
{
    ZBarReaderViewController *reader = [APZBarWrapper new];
    reader.wantsFullScreenLayout = NO;
    reader.readerDelegate = self;
    [reader.scanner setSymbology: 0
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    [reader.scanner setSymbology: ZBAR_QRCODE
                          config: ZBAR_CFG_ENABLE
                              to: 1];
    reader.readerView.zoom = 0.8;
    APLOG(kDebugScan, @"Returning reader %@", reader);
    return reader;
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol * sym = nil;
    for( sym in results) break;
    APScanResult * result = [APScanResult new];
    result.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    result.text = sym.data;
    APLOG(kDebugScan, @"Got scan result %@", result.text);
    [self closeReader:result];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self closeReader:nil];
}

-(void)closeReader:(APScanResult *)result
{
    [_delegate toggleScanner:^(UIViewController *them) {
        if( result )
        {
            [NSObject performBlock:^{
                [self attemptTransaction:result];
            } afterDelay:0.3];
        }
        else
        {
            [APPopup msgWithParent:them.view text:NSLocalizedString(@"QR Code scan was cancelled", "popup")];
        }
    }];
}

@end


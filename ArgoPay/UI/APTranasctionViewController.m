//
//  APTranasctionViewController.m
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APPopup.h"
#import "APTranasctionViewController.h"
#import "APTransaction.h"
#import "APMerchant.h"

@implementation APTranasctionViewController {
    APTransactionRequest * _transactionRequest;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __block APPopup * popup = [APPopup popupWithParent:self.view
                                          text:@"Contacting ArgoPay Server"
                                         flags:kPopupActivity];

    [self registerForBroadcast:kNotifyTransactionResult
                         block:^(APTranasctionViewController *me,
                                 APTransactionRequest *request) {
                             if( request.requestError )
                             {
                                 [popup dismiss];
                                 [self showError:request.requestError];
                             }
                             else
                             {
                                 APTransaction * result = request.transaction;
                                 me->_merchantItem.text = result.merchantItem;
                                 me->_merchantName.text = result.merchant.name;
                                 me->_grandTotal.text = [NSString stringWithFormat:@"$%.2f", [result.grandTotal floatValue]];
                                 [popup dismiss];
                             }
                             popup = nil;
                         }];
    
    [self registerForBroadcast:kNotifyTransactionComplete
                         block:^(APTranasctionViewController *me,
                                 APTransactionRequest *request) {
                             [NSObject performBlock:^{
                                 [me dismissViewControllerAnimated:YES completion:nil];
                             } afterDelay:0.2];
                         }];
    
    _transactionRequest = [[APTransactionRequest alloc] initWithScanResult:self.scanResult];
    
}

- (IBAction)cancelPayment:(id)sender
{
    [_transactionRequest cancel];
}

- (IBAction)approvePayment:(id)sender
{
    [_transactionRequest accept];
}

@end

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
#import "APRemoteStrings.h"
#import "APAccount.h"

@implementation APTranasctionViewController

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];

    _grandTotal.text = [NSString stringWithFormat:@"%.2f",[_statusResponse.TotalAmount floatValue]];
    _merchantName.text = _statusResponse.MerchName;
    _merchantItem.text = [_statusResponse.Amounts[0] valueForKey:@"Desc"]; // this can't be right
}

-(void)userAction:(NSString *)type
{
    APTransactionApprovalRequest *request = [APTransactionApprovalRequest new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.Approve = type;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [NSObject performBlock:^{
            [self broadcast:kNotifyTransactionUserActed payload:request];
        } afterDelay:0.2];
    }];
}

- (IBAction)cancelPayment:(id)sender
{
    [self userAction:kRemoteValueNO];
}

- (IBAction)approvePayment:(id)sender
{
    [self userAction:kRemoteValueYES];
}

@end

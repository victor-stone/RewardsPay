//
//  APTranasctionViewController.m
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APPopup.h"
#import "APTranasctionBillViewController.h"
#import "APTransaction.h"
#import "APRemoteStrings.h"
#import "APAccount.h"

/*
@implementation APTranasctionBillViewController

APLOGRELEASE

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _grandTotal.text = [NSString stringWithFormat:@"%.2f",[_statusResponse.TotalAmount floatValue]];
    _merchantName.text = _statusResponse.MerchName;
    _merchantCategory.text = _statusResponse.Category;
    
    _cancelButton.layer.masksToBounds = YES;
    _cancelButton.layer.cornerRadius = 8.0;
}

-(void)userAction:(NSString *)type
{
    APRequestTransactionApprove *request = [APRequestTransactionApprove new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.Approve = type;
    request.TransID = _transID;
    
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
*/
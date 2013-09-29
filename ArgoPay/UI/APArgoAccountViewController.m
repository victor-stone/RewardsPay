//
//  APArgoAccountViewController.m
//  ArgoPay
//
//  Created by victor on 9/28/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#include "APStrings.h"
#include "APAccount.h"
#include "APPopup.h"

@interface APArgoAccountViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *creditBalance;
@property (weak, nonatomic) IBOutlet UILabel *availableCredit;
@property (weak, nonatomic) IBOutlet UILabel *paymentDueDate;
@property (weak, nonatomic) IBOutlet UILabel *minimumPayment;
@property (weak, nonatomic) IBOutlet UIButton *transactionButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;

@property (nonatomic,strong) APAccountSummary *summary;
@end

@implementation APArgoAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton:_argoNavBar];
    
    UIImage * bg = [[UIImage imageNamed:kImageButtonBg]
                    resizableImageWithCapInsets:UIEdgeInsetsMake(5,10,5,10)
                    resizingMode:UIImageResizingModeStretch];
                    
    [_transactionButton setBackgroundImage:bg forState:UIControlStateNormal];
    NSString *empty = @"";
    _creditBalance.text = empty;
    _availableCredit.text = empty;
    _paymentDueDate.text = empty;
    _minimumPayment.text = empty;
    
    APAccount *account = [APAccount currentAccount];
    APAccountSummaryRequest *request = [[APAccountSummaryRequest alloc] init];
    request.AToken = account.AToken;
    
    APPopup *popup = [APPopup withNetActivity:self.view];
    [request performRequest:^(APAccountSummary*summary, NSError *err) {
        self.summary = summary;
        [popup dismiss];
    }];
}

-(void)setSummary:(APAccountSummary *)summary
{
    _creditBalance.text = [NSString stringWithFormat:@"$%.2f",[summary.AmountAvailable floatValue]];
    _availableCredit.text = [NSString stringWithFormat:@"$%.2f",[summary.AmountOutstanding floatValue]];
    _paymentDueDate.text = [summary formatDateField:@"LastPayDate"];
    _minimumPayment.text = [NSString stringWithFormat:@"$%.2f",[summary.AmountOutstanding floatValue]];
}

- (IBAction)seeTransaction:(id)sender
{
    [self presentVC:kViewHistory animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
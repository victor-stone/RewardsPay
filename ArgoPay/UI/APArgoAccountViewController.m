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
@property (weak, nonatomic) IBOutlet UIView *infoContainer;

@property (nonatomic,strong) APAccountSummary *summary;

@end

@implementation APArgoAccountViewController {
    bool _didLayerWork;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    APRequestStatementSummary *request = [[APRequestStatementSummary alloc] init];
    request.AToken = account.AToken;
    
    APPopup *popup = [APPopup withNetActivity:self.view];
    [request performRequest:^(APAccountSummary*summary) {
        self.summary = summary;
        [popup dismiss];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( !_didLayerWork )
    {
        CALayer *layer = _infoContainer.layer;
        layer.borderColor = [UIColor argoOrange].CGColor;
        layer.borderWidth = 2;
        layer.cornerRadius = 8.0;
        layer.masksToBounds = YES;
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        
        _didLayerWork = true;
    }
}
-(void)setSummary:(APAccountSummary *)summary
{
    _creditBalance.text = [NSString stringWithFormat:@"$%.2f",[summary.AmountOutstanding floatValue]];
    _availableCredit.text = [NSString stringWithFormat:@"$%.2f",[summary.AmountAvailable floatValue]];
    _paymentDueDate.text = [summary formatDateField:@"NextPayDate"];
    _minimumPayment.text = [NSString stringWithFormat:@"$%.2f",[summary.NetPayAmount floatValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

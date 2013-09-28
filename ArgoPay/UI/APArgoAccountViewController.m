//
//  APArgoAccountViewController.m
//  ArgoPay
//
//  Created by victor on 9/28/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#include "APStrings.h"

@interface APArgoAccountViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *creditBalance;
@property (weak, nonatomic) IBOutlet UILabel *availableCredit;
@property (weak, nonatomic) IBOutlet UILabel *paymentDueDate;
@property (weak, nonatomic) IBOutlet UILabel *minimumPayment;
@property (weak, nonatomic) IBOutlet UIButton *transactionButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;

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
}

- (IBAction)seeTransaction:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  APTranasctionViewController.h
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APTransactionStatusResponse;

@interface APTranasctionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *grandTotal;
@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *merchantCategory;

@property (nonatomic,strong) NSString *transID;
@property (nonatomic,strong) APTransactionStatusResponse *statusResponse;

@end

//
//  APTranasctionViewController.h
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APScanResult;

@interface APTranasctionViewController : UIViewController

@property (nonatomic,strong) APScanResult * scanResult;
@property (weak, nonatomic) IBOutlet UILabel *grandTotal;
@property (weak, nonatomic) IBOutlet UILabel *merchantItem;
@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

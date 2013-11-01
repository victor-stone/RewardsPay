//
//  APPinViewController.h
//  ArgoPay
//
//  Created by victor on 11/1/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPinViewController : UIViewController
@property (nonatomic,readonly) NSString * PIN;
@property (nonatomic,weak) IBOutlet UILabel * maskLabel;
@property (nonatomic,weak) IBOutlet UIBarButtonItem * doneButton;
@end


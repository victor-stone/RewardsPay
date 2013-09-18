//
//  APTranasctionViewController.m
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APTranasctionViewController.h"
#import "APPopup.h"

@interface APTranasctionViewController ()

@end

@implementation APTranasctionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    APPopup * popup = [APPopup popupWithParent:self.view
                                          text:@"Contacting ArgoPay Server"
                                         flags:kPopupActivity];
    
    [NSObject performBlock:^{
        [popup dismiss];
    } afterDelay:3.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

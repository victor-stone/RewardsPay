//
//  APLoginViewController.m
//  ArgoPay
//
//  Created by victor on 9/27/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APAccount.h"
#import "APStrings.h"
#import "APPopup.h"

@interface APLoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation APLoginViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_username becomeFirstResponder];
    
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 8.0;
    _submitButton.layer.backgroundColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1].CGColor;
    
}

- (IBAction)forgotPassword:(id)sender
{
}

- (IBAction)submit:(id)sender
{
    APPopup *popup = [APPopup withNetActivity:self.view];
    [_password resignFirstResponder];
    [_username resignFirstResponder];
    
    [APAccount login:_username.text password:_password.text block:^(APAccount *account, NSError *err) {
        if( err )
        {
            [popup dismiss];
            [self showError:err];
        }
        else
        {
            UIViewController *host = self.presentingViewController;
            [NSObject performBlock:^{
                [host dismissViewControllerAnimated:YES completion:^{
#warning Get to home from here...?
                }];
            } afterDelay:0.2];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == _username )
        [_password becomeFirstResponder];
    else
        [self submit:textField];
    return YES;
}

@end

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
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;

@end

@implementation APLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self argoPayIize];
    [self addBackButton:_argoNavBar];
    [_username becomeFirstResponder];
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
                    [NSObject performBlock:^{
                        [host navigateTo:kViewHome];
                    } afterDelay:0.5];
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

//
//  APLoginViewController.m
//  ArgoPay
//
//  Created by victor on 9/27/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APAccount.h"
#import "APStrings.h"

@interface APLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;

@end

@implementation APLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton:_argoNavBar];
}

- (IBAction)forgotPassword:(id)sender
{
}

- (IBAction)submit:(id)sender
{
    [APAccount login:_username.text password:_password.text block:^(APAccount *account, NSError *err) {
        if( err )
        {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

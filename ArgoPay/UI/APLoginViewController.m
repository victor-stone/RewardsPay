//
//  APLoginViewController.m
//  ArgoPay
//
//  Created by victor on 9/27/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

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

- (IBAction)forgotPassword:(id)sender {
}
- (IBAction)submit:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

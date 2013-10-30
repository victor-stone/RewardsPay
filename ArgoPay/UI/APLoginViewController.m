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
#import "APTransactionViewController.h"
#import "VSNavigationViewController.h"

#ifndef NUM_SECRET_QUESTIONS
#define NUM_SECRET_QUESTIONS 3
#endif

@interface APPINHoster : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (readonly) NSUInteger PIN;
@end

@implementation APPINHoster {
    NSUInteger _pin[4];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 8.0;
}

-(NSUInteger)PIN
{
    NSUInteger pin = 0;
    for( NSUInteger i = 0; i < 4; i++ )
    {
        pin *= 10;
        pin += _pin[i];
    }
    return pin;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    _pin[component] = row;
}

@end

@interface APQuickScanGetPIN : APPINHoster
@end

@implementation APQuickScanGetPIN

- (IBAction)submitPIN:(id)sender
{
    NSUInteger userPIN = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingUserPIN];
    NSUInteger pin = self.PIN;
    if( userPIN && (userPIN == pin) )
    {
        [self performSegueWithIdentifier:kSegueUnwindToGetPIN sender:self];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Invalid PIN"
                                                         message:@"Your PIN number doesn't match our records."
                                                        delegate:nil
                                               cancelButtonTitle:@"Try Again"
                                               otherButtonTitles:nil];
        [alert show];
    }
}

@end

@interface APWelcomeViewController : APTransactionViewController
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end
@implementation APWelcomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _signInButton.layer.masksToBounds = YES;
    _signInButton.layer.cornerRadius = 8.0;
}

-(IBAction)unwindToLogin:(UIStoryboardSegue *)segue
{
    
}

/**
 *  Intercept this so we can ask for PIN.
 *
 *  @param segue (ignored)
 */
-(IBAction)unwindFromCamera:(UIStoryboardSegue *)segue
{
    [self storeCameraResults:segue.sourceViewController];
    [NSObject performBlock:^{
        [self performSegueWithIdentifier:kSegueSignInToGetPIN sender:self];
    } afterDelay:0.6];
}

-(IBAction)unwindFromGetPIN:(UIStoryboardSegue *)segue
{
    [APAccount attempLoginWithDefaults:^(APAccount *account) {
        if( account )
        {
            [self attemptTransaction];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No account information"
                                                             message:@"We can't find auto-login account information"
                                                            delegate:nil
                                                   cancelButtonTitle:@"Continue with log in"
                                                   otherButtonTitles:nil];
            [alert show];
        }
    }];
}

-(IBAction)unwindFromCancelPIN:(UIStoryboardSegue *)segue
{
    [self clearTransaction];
}
@end

@interface APPINMaker : APPINHoster
@end

@implementation APPINMaker

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustViewForiOS7];
}


- (IBAction)doneTap:(id)sender
{
    NSUInteger pin = self.PIN;
    if( pin )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:pin forKey:kSettingUserPIN];
        [self broadcast:kNotifyUserLoginStatus payload:self];

    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Blank PIN"
                                                         message:@"Please pick a PIN number."
                                                        delegate:nil
                                               cancelButtonTitle:@"Continue with log in"
                                               otherButtonTitles:nil];
        [alert show];
    }
}

@end

@interface APLoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation APLoginViewController {
    APPopup * _popup;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_username becomeFirstResponder];
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 8.0;
    NSString * name = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingUserLoginName];
    _username.text = name;
}

- (IBAction)submit:(id)sender
{
    _popup = [APPopup withNetActivity:self.view];
    [_password resignFirstResponder];
    [_username resignFirstResponder];
    
    [APAccount login:_username.text
            password:_password.text
               block:^(APAccount *account)
    {
        [_popup dismiss];
        _popup = nil;
        if( account )
        {
            NSUInteger pin = [[NSUserDefaults standardUserDefaults] integerForKey:kSettingUserPIN];
            if( pin )
            {
                [self broadcast:kNotifyUserLoginStatus payload:self];
            }
            else
            {
                [self performSegueWithIdentifier:kSegueLoginToMakePIN sender:self];
            }
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


@interface APForgotPasswordViewController : UITableViewController<UITextFieldDelegate>

@end


@implementation APForgotPasswordViewController {
    NSArray * _questions;
    NSMutableArray * _answers;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _questions = @[@"Name of first pet.",
                   @"Mother's DJ name.",
                   @"BFF who stole your GF/BF."];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for( UITextField * textField in self.textFields )
        textField.delegate = self;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _questions[section];
}

-(UINavigationItem *)navigationItem
{
    UINavigationItem * item = [super navigationItem];
    if( !item.rightBarButtonItems )
    {
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(submit:)];
        item.rightBarButtonItems = @[bbi];
    }
    item.hidesBackButton = YES;
    return item;
}

-(NSArray *)textFields
{
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:3];
    for( int i = 0; i < 3; i++ )
    {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        [arr addObject:cell.contentView.subviews[0]];
    }
    return arr;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSUInteger next = (textField.tag + 1) % 3;
    textField = self.textFields[next];
    [textField becomeFirstResponder];
    return YES;
}


-(IBAction)submit:(id)sender
{
    BOOL ok = YES;
 
    for( UITextField * textField in self.textFields )
    {
        if( textField.text.length == 0 )
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Missing answer"
                                                             message:@"Can't leave a field blank"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
            ok = NO;
            break;
        }
    }
    
    if (ok)
    {
        [self.vsNavigationController performBack];
    }
}
@end

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


@interface APQuickScanGetPIN : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (readonly) NSUInteger PIN;
@end

@implementation APQuickScanGetPIN {
    NSUInteger _pin[4];
}

-(NSUInteger)PIN
{
    NSUInteger pin = 0;
    for( NSUInteger i = 0; i < 4; i++ )
        pin |= (_pin[i] << (i*4));
    return pin;
}

- (IBAction)submitPIN:(id)sender
{
    NSUInteger userPIN = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingUserPIN];
    NSUInteger pin = self.PIN;
    if( userPIN == pin )
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

-(IBAction)unwindFromError:(UIStoryboardSegue *)segue
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
    [self performSegueWithIdentifier:kSegueSignInToGetPIN sender:self];
}

-(IBAction)unwindFromGetPIN:(UIStoryboardSegue *)segue
{
    [self attemptTransaction];
}

-(IBAction)unwindFromCancelPIN:(UIStoryboardSegue *)segue
{
    [self clearTransaction];
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
        // call will trigger switch to main view
        
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



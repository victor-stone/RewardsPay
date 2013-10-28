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
        pin |= (_pin[i] << (i*4));
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
        NSUInteger pin = 0; // [[NSUserDefaults standardUserDefaults] integerForKey:kSettingUserPIN];
        if( pin )
        {
            [self broadcast:kNotifyUserLoginStatus payload:self];
        }
        else
        {
            [self performSegueWithIdentifier:kSegueLoginToMakePIN sender:self];
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

@interface APAnswerField : UITextField

@end

@implementation APAnswerField

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)theKey {
    
    CATransition *theAnimation = nil;
    // kCAOnOrderIn
    if ( [theKey isEqualToString:@"hidden"] ) {
        
        theAnimation = [[CATransition alloc] init];
        theAnimation.duration = 0.2;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        theAnimation.type = kCATransitionPush;
        theAnimation.subtype = kCATransitionFromRight;
    }
    return theAnimation;
}


@end

@interface APForgotPasswordViewController : UIViewController
@property (strong,nonatomic) IBOutletCollection(APAnswerField) NSArray * answers;

@end

@interface APForgotPasswordViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation APForgotPasswordViewController {
    NSUInteger _currentQuestion;
    NSArray * _questions;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _questions = @[@"Name of first pet.",
                   @"Mother's DJ name.",
                   @"BFF who stole your GF/BF."];

}
- (APAnswerField *)changeQuestion:(NSUInteger)newQuestion picker:(UIPickerView *)pickerView
{
    APAnswerField * oldField = _answers[_currentQuestion];
    oldField.hidden = YES;
    APAnswerField * nextField = _answers[newQuestion];
    nextField.hidden = NO;
    _currentQuestion = newQuestion;
    return nextField;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel * label = (UILabel *)view;
    if( !label )
    {
        label = [[UILabel alloc] init];
        label.minimumScaleFactor = 0.5;
    }
    label.text = _questions[row];
    [label sizeToFit];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    [self changeQuestion:row picker:pickerView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger nextQ = (_currentQuestion + 1) % NUM_SECRET_QUESTIONS;
    APAnswerField * nextA = [self changeQuestion:nextQ picker:_picker];
    if( nextQ > 0 )
    {
        [nextA becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    [_picker selectRow:nextQ inComponent:0 animated:YES];
    return YES;
}

@end

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


@interface APSignUp2ViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation APSignUp2ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _nextButton.layer.masksToBounds = YES;
    _nextButton.layer.cornerRadius = 8.0;
    _password.delegate = self;
    _confirmPassword.delegate = self;
    
}
- (IBAction)nextTap:(id)sender
{
    NSString * errMessage = nil;
    if( !_password.text.length )
        errMessage = NSLocalizedString(@"You must fill in a password.", @"signup");
    else if( !_confirmPassword.text.length )
        errMessage = NSLocalizedString(@"You must confirm your password.", @"signup");
    else if( ![_confirmPassword.text isEqualToString:_password.text] )
        errMessage = NSLocalizedString(@"The password and confirm password must match.", @"signup");
    
    if( errMessage )
    {
        NSString * title = NSLocalizedString(@"Sign Up Error", @"signup");
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:errMessage delegate:nil cancelButtonTitle:@"Yup, OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:kSegueSignUp2to3 sender:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == _password )
        [_confirmPassword becomeFirstResponder];
    else
        [self nextTap:textField];
    return YES;
}

@end


@interface APWelcomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end
@implementation APWelcomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _signUpButton.layer.masksToBounds = YES;
    _signUpButton.layer.cornerRadius = 8.0;
    _signInButton.layer.masksToBounds = YES;
    _signInButton.layer.cornerRadius = 8.0;
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

@interface APSignUp3ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (strong,nonatomic) IBOutletCollection(APAnswerField) NSArray * answers;

@end

@interface APSignUp3ViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@end

@implementation APSignUp3ViewController {
    NSArray * _questionSet;
    NSUInteger _selectedQuestion;
    NSUInteger * _pickedQuestion;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    static NSUInteger s_pickedQuestions[3];
    
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 8.0;
    _resetButton.layer.masksToBounds = YES;
    _resetButton.layer.cornerRadius = 8.0;
    _pickedQuestion = s_pickedQuestions;
    _pickedQuestion[0] = _pickedQuestion[1] = _pickedQuestion[2] = -1UL;
    
    _questionSet = @[ @"Name of first pet.",
                      @"Mother's maiden name.",
                      @"BFF who stole your GF/BF.",
                      @"Favorite NYC subway line.",
                      @"Least fav Glee cast member.",
                      @"1st time U were Rickrolled.",
                      @"Your mother winced when..."];
}

- (IBAction)changeQuestion:(UISegmentedControl *)sender
{
    NSUInteger newSeg = sender.selectedSegmentIndex;
    APAnswerField * oldField = _answers[_selectedQuestion];
    oldField.hidden = YES;
    APAnswerField * nextField = _answers[newSeg];
    nextField.hidden = NO;
    _selectedQuestion = newSeg;
}

- (IBAction)submit:(id)sender {
}

- (IBAction)reset:(id)sender {
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _questionSet.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _questionSet[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedQuestion = row;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

@interface APSignUp1ViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation APSignUp1ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _nextButton.layer.masksToBounds = YES;
    _nextButton.layer.cornerRadius = 8.0;
    _email.delegate = self;
    _username.delegate = self;
}
- (IBAction)nextTap:(id)sender
{
    NSString * errMessage = nil;
    if( !_email.text.length )
        errMessage = NSLocalizedString(@"You must fill in an email address.", @"signup");
    else if( !_username.text.length )
        errMessage = NSLocalizedString(@"You must fill in a username.", @"signup");
    
    if( errMessage )
    {
        NSString * title = NSLocalizedString(@"Sign Up Error", @"signup");
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:errMessage delegate:nil cancelButtonTitle:@"Yup, OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:kSegueSignUp1to2 sender:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == _email )
        [_username becomeFirstResponder];
    else
        [self nextTap:textField];
    return YES;
}

-(IBAction)unwindToSignUp1:(UIStoryboardSegue *)segue
{
    
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

-(IBAction)unwindFromError:(UIStoryboardSegue *)segue
{
    [_popup dismiss];
    _popup = nil;
}
@end



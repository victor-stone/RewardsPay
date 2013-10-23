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

#define NUM_SECRET_QUESTIONS 3
#define HEADER_COMPONENT 0
#define QUESTIONS_COMPONENT 1

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
    NSUInteger _currentQuestionSet;
    
    NSUInteger * _pickedQuestions;
    
    NSArray * _questionSets;
    NSMutableArray * _headers;
    
    NSMutableArray * _currentStructure;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    static NSUInteger s_pickedQuestions[NUM_SECRET_QUESTIONS];
    
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 8.0;
    _resetButton.layer.masksToBounds = YES;
    _resetButton.layer.cornerRadius = 8.0;
    _pickedQuestions = s_pickedQuestions;
    memset(_pickedQuestions, 0, sizeof(s_pickedQuestions));
    
    _questionSets = @[ @[@"Name of first pet.",
                         @"Mother's DJ name.",
                         @"BFF who stole your GF/BF."],
                       @[@"Favorite NYC subway line.",
                         @"Least fav Glee cast member.",
                         @"1st time U were Rickrolled."],
                       @[@"Juice is to Hat as...",
                         @"OKC strikes at the ___ of ____.",
                         @"Your mother winced when..."]];

    _headers = [NSMutableArray arrayWithCapacity:NUM_SECRET_QUESTIONS];
    for( NSUInteger i = 0; i < NUM_SECRET_QUESTIONS; i++ )
        [_headers addObject:[NSString stringWithFormat:@"#%d",i+1]];
    
    _currentStructure = [NSMutableArray arrayWithCapacity:2];
    _currentStructure[HEADER_COMPONENT] = _headers;
    _currentStructure[QUESTIONS_COMPONENT] = _questionSets[0];
}

- (void)changeQuestion:(NSUInteger)newSeg picker:(UIPickerView *)pickerView
{
    APAnswerField * oldField = _answers[_currentQuestionSet];
    oldField.hidden = YES;
    APAnswerField * nextField = _answers[newSeg];
    nextField.hidden = NO;
    _currentQuestionSet = newSeg;
    _currentStructure[QUESTIONS_COMPONENT] = _questionSets[_currentQuestionSet];
    [pickerView reloadComponent:1];
    NSUInteger row = _pickedQuestions[_currentQuestionSet];
    [pickerView selectRow:row inComponent:1 animated:NO];
}

- (IBAction)submit:(id)sender {
}

- (IBAction)reset:(id)sender {
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_currentStructure[component] count];
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
    label.text = _currentStructure[component][row];
    [label sizeToFit];
    return label;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat w = self.view.frame.size.width;
    if( component == 0 )
        return w * 0.15;
    return w * 0.85;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    if( component == HEADER_COMPONENT )
    {
        if( row != _currentQuestionSet )
        {
            [self changeQuestion:row picker:pickerView];
        }
    }
    else
    {
        _pickedQuestions[_currentQuestionSet] = row;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.view becomeFirstResponder];
    NSUInteger nextQSet = (_currentQuestionSet + 1) % NUM_SECRET_QUESTIONS;
    [self changeQuestion:nextQSet picker:_picker];
    [_picker selectRow:nextQSet inComponent:HEADER_COMPONENT animated:YES];
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
    [_email resignFirstResponder];
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



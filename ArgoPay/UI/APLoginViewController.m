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
#import "VSTabNavigatorViewController.h"


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
            [self broadcast:kNotifyUserLoginStatus payload:account];
        }
    }];
}

- (IBAction)forgotPassword:(id)sender
{
    if( _username.text.length == 0 )
    {
        NSString * title = NSLocalizedString(@"Missing email", @"login");
        NSString * msg = NSLocalizedString(@"You need to enter an email address", @"login");
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show
         ];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:_username.text forKey:kSettingUserLoginName];
        [self performSegueWithIdentifier:kSegueLoginToValidateGet sender:self];
    }
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for( UITextField * textField in self.textFields )
        textField.delegate = self;

    if( !_questions )
    {
        APPopup *popup = [APPopup withNetActivity:self.view];
        _questions = [NSMutableArray new];
        APRequestValidateGet *request = [APRequestValidateGet new];
        request.Email = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingUserLoginName];
        [request performRequest:^(APValidateGet *validateGet) {
            [popup dismiss];
            _questions = @[ validateGet.Ques1, validateGet.Ques2, validateGet.Ques3 ];
            [self.tableView reloadData];
        }];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _questions.count > section ? _questions[section] : @"Question...";
}

-(UINavigationItem *)navigationItem
{
    UINavigationItem * item = [super navigationItem];
    if( !item.rightBarButtonItems )
    {
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(submit:)];
        bbi.tintColor = [UIColor whiteColor];
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
        APPopup * popup = [APPopup withNetActivity:self.view delay:YES];
        APRequestValidateTest * request = [APRequestValidateTest new];
        request.Email = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingUserLoginName];
        NSArray * textFields = self.textFields;
        request.Ans1 = ((UITextField *)textFields[0]).text;
        request.Ans2 = ((UITextField *)textFields[1]).text;
        request.Ans3 = ((UITextField *)textFields[2]).text;
        [request performRequest:^(APValidateTest * test) {
            [popup dismiss];
            [APAccount loginWithEmail:request.Email andToken:test.AToken];
            [self broadcast:kNotifyUserLoginStatus payload:[APAccount currentAccount]]; 
         }
         errorHandler:^(NSError *err) {
             [popup dismiss];
             if( [err isKindOfClass:[APError class]] )
             {
                 NSString * title = NSLocalizedString(@"Validation Error", @"login");
                 UIAlertView * view;
                 view = [[UIAlertView alloc] initWithTitle:title
                                                   message:err.localizedDescription
                                                  delegate:nil
                                         cancelButtonTitle:@"Try again..."
                                         otherButtonTitles:nil];
                 [view show];
             }
             else
             {
                 [self broadcast:kNotifySystemError payload:err];
             }
         }];
    }
}
@end

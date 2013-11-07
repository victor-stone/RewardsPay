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


@interface APWelcomeViewController : APTransactionViewController
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end
@implementation APWelcomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _signInButton.layer.masksToBounds = YES;
    _signInButton.layer.cornerRadius = 8.0;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        [self.vsNavigationController.navigationBar setTintColor:[UIColor argoOrange]];
}

-(IBAction)unwindToLogin:(UIStoryboardSegue *)segue
{
    
}

@end

@interface APForgotPasswordViewController : UITableViewController<UITextFieldDelegate>
@property (nonatomic,strong) NSString * loginUserName;
@end

@interface APLoginViewController : UIViewController<UITextFieldDelegate,MFMailComposeViewControllerDelegate>
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
    _username.text = @"";
    
    UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithTitle:@"Help"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(showContactMail:)];
    self.navigationItem.rightBarButtonItems = @[bbi];
}

-(void)showContactMail:(id)sender
{
    if( [MFMailComposeViewController canSendMail] )
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Support"];
        [mailViewController setToRecipients:@[@"support@argopay.com"]];
        
        UINavigationBar * bar = mailViewController.navigationBar;
        bar.barStyle = UIBarStyleBlack; // mybar.barStyle;
        bar.tintColor = [UIColor whiteColor];
        bar.translucent = NO;
        bar.barTintColor = [UIColor blackColor];
        
        [self presentViewController:mailViewController
                           animated:YES
                         completion:^{
                             bar.translucent = NO;
                         }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Mail not configured", @"login")
                              message:NSLocalizedString(@"This device is not configured for sending Email. Please configure the Mail settings in the Settings app.", @"login")
                              delegate: nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"login")
                              otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString * feedbackMsg = nil;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            feedbackMsg = @"Result: Mail sending canceled";
            break;
        case MFMailComposeResultSaved:
            feedbackMsg = @"Result: Mail saved as draft";
            break;
        case MFMailComposeResultSent:
            feedbackMsg = @"Result: Mail sent";
            break;
        case MFMailComposeResultFailed:
            feedbackMsg = @"Result: Mail sending failed";
            break;
        default:
            feedbackMsg = @"Result: Mail not sent";
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView * view = [[UIAlertView alloc] initWithTitle:@"Support"
                                                        message:feedbackMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [NSObject performBlock:^{
            [view show];
        } afterDelay:0.2];
    }];
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
        NSString * title = NSLocalizedString(@"Missing login name", @"login");
        NSString * msg = NSLocalizedString(@"You need to enter a user name", @"login");
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }
    else
    {
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueLoginToValidateGet] )
    {
        APForgotPasswordViewController * vc = segue.destinationViewController;
        vc.loginUserName = _username.text;
    }
}
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
        request.UserName = _loginUserName;
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
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
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
        request.UserName = _loginUserName;
        NSArray * textFields = self.textFields;
        request.Ans1 = ((UITextField *)textFields[0]).text;
        request.Ans2 = ((UITextField *)textFields[1]).text;
        request.Ans3 = ((UITextField *)textFields[2]).text;
        [request performRequest:^(APValidateTest * test) {
            [popup dismiss];
            [APAccount loginWithUserName:request.UserName andToken:test.AToken];
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

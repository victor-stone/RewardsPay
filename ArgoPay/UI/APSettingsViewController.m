//
//  APSettingsViewController.m
//  ArgoPay
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#import "VSSettings.h"
#import "APStrings.h"
#import "VSNavigationViewController.h"
#import "APPinViewController.h"
#import "APAccount.h"
#import "APRemoteStrings.h"

@interface APSettingNavigationController : UINavigationController
@end

@implementation APSettingNavigationController
-(BOOL)navigationBarHidden
{
    return YES;
}
@end

@interface APSettingsViewController : VSSettingsExtensions
@end

@implementation APSettingsViewController

APLOGRELEASE

- (IBAction)done:(id)sender
{
    [[self vsNavigationController] performBack];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( self.navigationController.topViewController == self )
    {
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done:)];
        self.navigationItem.leftBarButtonItem  = bbi;

#ifndef ALLOW_DEBUG_SETTINGS
        [self setHiddenKeys:[NSSet setWithArray:@[kSettingDebug]] animated:NO];
#endif
    }
}
@end

@interface APResetPasswordViewController : UITableViewController<UITextFieldDelegate>
@end

@implementation APResetPasswordViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUInteger tag = 0;
    for( UITextField * textField in self.textFields )
    {
        textField.delegate = self;
        textField.tag = tag++;
    }
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


-(BOOL)doneResetPassword:(id)sender
{
    NSArray *       textFields  = self.textFields;
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    NSString *      title       = NSLocalizedString(@"Error", @"Reset Password");
    NSString *      msg         = nil;
    
    
    NSString * oldPassword, * currentPassword, * newPassword, * confirmPassword;
    
    UITextField *tf = textFields[0];
    oldPassword = tf.text;
    currentPassword = [defaults stringForKey:kSettingUserLoginPassword];
    
    if( ![oldPassword isEqualToString:currentPassword] )
    {
        msg = NSLocalizedString(@"Old password doesn't match our records", @"Account settings");
    }
    else
    {
        tf = textFields[1];
        newPassword = tf.text;
        tf = textFields[2];
        confirmPassword = tf.text;
        if( !newPassword )
        {
            msg = NSLocalizedString(@"New password can't be blank", @"Account settings");
        }
        else if( ![newPassword isEqualToString:confirmPassword] )
        {
            msg = NSLocalizedString(@"Confirm password doesn't match new password", @"Account settings");
        }
        else
        {
            [defaults setObject:newPassword forKey:kSettingUserLoginPassword];
        }
    }

    if( msg )
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
    
}
@end


@interface APResetPasswordWrapper : UIViewController
@property (nonatomic,weak) APResetPasswordViewController * vc;
@end

@implementation APResetPasswordWrapper

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustViewForiOS7];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _vc = segue.destinationViewController;
}

-(IBAction)doneResetPassword:(id)sender
{
    if( [_vc doneResetPassword:sender] == YES )
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)cancelResetPassword:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end



@interface APAccountSettingsViewController : UITableViewController
@end


@implementation APAccountSettingsViewController {
    __weak UILabel * _pinLabel;
    __weak UISwitch * _pinSwitch;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    for( UIView * view in cell.contentView.subviews )
    {
        if( [view isKindOfClass:[UISwitch class]] )
        {
            _pinSwitch = (id)view;
            
            [_pinSwitch addTarget:self
                           action:@selector(pinSwitchChanged:)
                 forControlEvents:UIControlEventValueChanged];
            
            break;
        }
    }
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    _pinLabel = (id)cell.contentView.subviews[0];
    [self updatePinSwitches];
}

-(void)updatePinSwitches
{
    BOOL pinEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingUserEnablePIN];
    _pinSwitch.on = pinEnabled;
    _pinLabel.textColor = pinEnabled ? [UIColor blackColor] : [UIColor lightGrayColor];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 1 && indexPath.section == 2 )
        return _pinSwitch.on;
    if( indexPath.row == 0 && indexPath.section == 0 )
        return NO;
    return YES;
}

-(IBAction)pinSwitchChanged:(UISwitch *)switcher
{
    BOOL enablePIN = switcher.on;
    [[NSUserDefaults standardUserDefaults] setBool:enablePIN forKey:kSettingUserEnablePIN];
    [self updatePinSwitches];
    
    // um, is this the place for this?
    APRequestSetPINRequired * request = [APRequestSetPINRequired new];
    APAccount * account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.PINRequired = enablePIN ? kRemoteValueYES : kRemoteValueNO;
    [request performRequest:^(id data) {
        //
    }];
}

-(IBAction)unwindFromPINCancel:(UIStoryboardSegue *)segue
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)unwindFromSubmitPin:(UIStoryboardSegue *)segue
{
    APPinViewController * vc = segue.sourceViewController;
    NSString * PIN = vc.PIN;
    APRequestSetPIN * request = [APRequestSetPIN new];
    APAccount * account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.PIN = PIN;
    [request performRequest:^(id data) {
        //
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

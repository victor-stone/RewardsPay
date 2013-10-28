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

@implementation APSettingsViewController {
}

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


@interface APAccountSettingsViewController : IASKAppSettingsViewController<IASKSettingsDelegate>

@end

@implementation APAccountSettingsViewController {
    BOOL _passwordShowing;
    BOOL _pinShowing;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.showDoneButton = YES;
    self.showCreditsFooter = NO;
    self.file = @"Account";
    self.navigationItem.hidesBackButton = YES;
    self.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kSettingUserLoginOldPIN];
    [defaults setObject:nil forKey:kSettingUserLoginNewPIN];
    [defaults setObject:nil forKey:kSettingUserLoginPINConfirm];
    [defaults setObject:nil forKey:kSettingUserLoginOldPassword];
    [defaults setObject:nil forKey:kSettingUserLoginNewPassword];
    [defaults setObject:nil forKey:kSettingUserLoginPasswordConfirm];
    
    [self setHiddenKeys:[NSSet setWithArray:@[kSettingUserLoginOldPIN,
                                              kSettingUserLoginNewPIN,
                                              kSettingUserLoginPINConfirm,
                                              kSettingUserLoginOldPassword,
                                              kSettingUserLoginNewPassword,
                                              kSettingUserLoginPasswordConfirm
                                              ]] animated:NO];
    
    __block BOOL bSettingSetting = NO;
    
    [self registerForBroadcast:kNotifyUserSettingChanged block:^(APAccountSettingsViewController *me, NSDictionary *d) {
        if( !bSettingSetting )
        {
            NSString * pinStr = nil;
            NSString * key;
            for( key in @[kSettingUserLoginNewPIN, kSettingUserLoginOldPIN, kSettingUserLoginPINConfirm] )
            {
                pinStr = d[key];
                if( pinStr )
                    break;
            }

            if( pinStr )
            {
                if( pinStr.length > 4 )
                {
                    pinStr = [pinStr stringByPaddingToLength:4 withString:@"" startingAtIndex:0];
                    bSettingSetting = YES;
                    [[NSUserDefaults standardUserDefaults] setObject:pinStr forKey:key];
                    UITextView * textView = [me firstResponder];
                    textView.text = pinStr;
                    bSettingSetting = NO;
                }
            }
        }
    }];
}

-(void)setDelegate:(id)delegate
{
    [super setDelegate:self];
}

-(void)hideKeys
{
    NSArray * passwordFields = _passwordShowing ? @[] : @[
                                 kSettingUserLoginOldPassword,
                                 kSettingUserLoginNewPassword,
                                 kSettingUserLoginPasswordConfirm
                                 ];
    NSArray * pinFields = _pinShowing ? @[] : @[kSettingUserLoginOldPIN,
                                                kSettingUserLoginNewPIN,
                                                kSettingUserLoginPINConfirm
                                                ];
    
    NSMutableArray * fieldsToHide = [NSMutableArray arrayWithArray:passwordFields];
    [fieldsToHide addObjectsFromArray:pinFields];
    [self setHiddenKeys:[NSSet setWithArray:fieldsToHide] animated:YES];
}


-(void)settingsViewController:(IASKAppSettingsViewController *)sender
     buttonTappedForSpecifier:(IASKSpecifier *)specifier
{
    if( [specifier.key isEqualToString:kSettingChangePassword] )
    {
        _passwordShowing = !_passwordShowing;
    }
    else if( [specifier.key isEqualToString:kSettingChangePIN] )
    {
        _pinShowing = !_pinShowing;
    }
    [self hideKeys];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    NSString * title = NSLocalizedString(@"Error", @"Account settings");
    NSString * msg = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if( _passwordShowing )
    {
        NSString * oldPassword, * currentPassword, * newPassword, * confirmPassword;
        
        oldPassword = [defaults stringForKey:kSettingUserLoginOldPassword];
        
        if( oldPassword.length > 0 )
        {
            currentPassword = [defaults stringForKey:kSettingUserLoginPassword];
            if( ![oldPassword isEqualToString:currentPassword] )
            {
                msg = NSLocalizedString(@"Old password doesn't match our records", @"Account settings");
            }
            else
            {
                newPassword = [defaults stringForKey:kSettingUserLoginNewPassword];
                confirmPassword = [defaults stringForKey:kSettingUserLoginPasswordConfirm];
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
        }
        
    }
    
    if( _pinShowing && !msg )
    {
        NSUInteger newPIN, confirmPIN;
        
        NSUInteger oldPIN = [defaults integerForKey:kSettingUserLoginOldPIN];
        
        if( oldPIN > 0 )
        {
            if( !msg )
            {
                NSUInteger currentPIN = [defaults integerForKey:kSettingUserPIN];
                if( oldPIN != currentPIN )
                {
                    msg = NSLocalizedString(@"Old PIN number doesn't match our records", @"Account settings");
                }
            }
            
            if( !msg )
            {
                newPIN = [defaults integerForKey:kSettingUserLoginNewPIN];
                if( newPIN < 1 )
                {
                    msg = NSLocalizedString(@"Invalid PIN number", @"Account settings");
                }
            }
            
            if( !msg )
            {
                confirmPIN = [defaults integerForKey:kSettingUserLoginPINConfirm];
                if( newPIN != confirmPIN )
                {
                    msg = NSLocalizedString(@"The confirm PIN number doesn't match the new PIN number", @"Account settings");
                }
                else
                {
                    [defaults setInteger:newPIN forKey:kSettingUserPIN];
                }
            }
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
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

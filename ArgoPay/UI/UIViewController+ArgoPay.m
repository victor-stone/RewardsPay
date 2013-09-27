//
//  UIViewController+ArgoPay.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "UIViewController+ArgoPay.h"
#import "APStrings.h"
#import "APPopup.h"
#import "APAppDelegate.h"
#import "APAccount.h"

@implementation UIViewController (ArgoPay)

void * kTargetMapAssociationKey = &kTargetMapAssociationKey;

-(void)invokeMenuItem:(id)sender
{
    NSMutableDictionary * _map = [self associatedValueForKey:kTargetMapAssociationKey];
    NSObject * obj = sender;
    APMenuBlock block = _map[@(obj.hash)];
    block(self,sender);
}


-(NSMutableDictionary *)targetMap
{
    NSMutableDictionary * _map = [self associatedValueForKey:kTargetMapAssociationKey];
    if( !_map )
    {
        _map = [NSMutableDictionary new];
        [self associateValue:_map withKey:kTargetMapAssociationKey];
    }
    return _map;
}

-(UIBarButtonItem *)barButtonForImage:(NSString *)imgName
                                title:(NSString *)title
                                block:(APMenuBlock)block
{
    UIImage * image = [UIImage imageNamed:imgName];
    UIButton * button = [[UIButton alloc] initWithFrame:(CGRect){0,0,kBarButtonSize,kBarButtonSize}];
    button.showsTouchWhenHighlighted = YES;
    button.backgroundColor = [UIColor clearColor];
    if( title )
    {
        button.titleLabel.text = title;
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    else
    {
        [button setImage:image forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(invokeMenuItem:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableDictionary * _map = self.targetMap;
    _map[@(button.hash)] = [block copy];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)addHomeButton:(UINavigationBar *)bar
{
    UIBarButtonItem * bbi = [self barButtonForImage:kImageHome
                                              title:nil
                                              block:^(UIViewController *me, id button) {
                                                  [me navigateTo:kViewHome];
                                              }];
    bar.topItem.leftBarButtonItems = @[bbi];
    
}

-(void)addLoginButton:(UINavigationBar *)bar
{
    BOOL isLoggedIn = [[APAccount sharedInstance] isLoggedIn];
    NSString *const image = isLoggedIn ? kImageLogout : kImageLogin;
    UIBarButtonItem * bbi = [self barButtonForImage:image
                                              title:nil
                                              block:^(UIViewController *me, id button) {
                                                  [me toggleLogin:bar];
                                              }];
    bar.topItem.rightBarButtonItem = bbi;
}

-(void)toggleLogin:(UINavigationBar *)bar
{
    APAccount *account = [APAccount sharedInstance];
    if( account.isLoggedIn )
    {
        [account logUserOut];
        [self addLoginButton:bar];
        NSString *msg = NSLocalizedString(@"You have been logged out", @"Log out button");
        [APPopup msgWithParent:self.view text:msg dismissBlock:^{
            [self broadcast:kNotifyUserLoginStatusChanged payload:account when:0.2];
        }];
    }
    else
    {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewLogin];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)addBackButton:(UINavigationBar *)bar
{
    UIBarButtonItem * bbBack = [self barButtonForImage:kImageBack
                                                 title:NSLocalizedString(@"Back", "Navigation button")
                                                 block:^(UIViewController *me, id sender)
                                {
                                    [me.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                }];
    bar.topItem.leftBarButtonItem = bbBack;
    
}

-(void)navigateTo:(NSString *)vcName
{
    if( self.parentViewController )
       [self.parentViewController navigateTo:vcName];
}

-(void)showError:(NSError *)error
{
    APAppDelegate * ad = (APAppDelegate *)([UIApplication sharedApplication].delegate);
    UIViewController * host = ad.window.rootViewController;
    if( host.presentedViewController )
        host = host.presentedViewController;
    
    if( [host isBeingDismissed] || [host isBeingPresented] )
    {
        [NSObject performBlock:^{
            [self showError:error];
        } afterDelay:0.3];
        return;
    }
    
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewError];
    [vc setValue:error forKey:@"errorObj"];
    [host presentViewController:vc animated:YES completion:nil];
}

@end

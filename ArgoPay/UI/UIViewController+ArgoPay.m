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
void * kHasLoginWatcherKey = &kHasLoginWatcherKey;
void * kDismissBlockKey = &kDismissBlockKey;

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
                                              block:^(UIViewController *me, id button)
                             {
                                 if( [[APAccount currentAccount] isLoggedIn] )
                                     [me navigateTo:kViewHome];
                                 else
                                     [me toggleLogin:bar];
                                     
                             }];
    bar.topItem.leftBarButtonItems = @[bbi];
    
}

-(void)addRightButton:(UINavigationBar *)bar button:(UIBarButtonItem *)bbi
{
    [self addRightButton:bar button:bbi replaceIndex:-1];
}

-(void)addRightButton:(UINavigationBar *)bar
               button:(UIBarButtonItem *)bbi
         replaceIndex:(NSInteger)atIndex
{
    NSMutableArray *arr = nil;
    if( bar.topItem.rightBarButtonItems )
    {
        arr = [NSMutableArray arrayWithArray:bar.topItem.rightBarButtonItems];
        if( atIndex == -1 )
            [arr addObject:bbi];
        else
            [arr replaceObjectAtIndex:atIndex withObject:bbi];
        
    }
    else
    {
        arr = [NSMutableArray new];
        [arr addObject:bbi];
    }
    bar.topItem.rightBarButtonItems = arr;
}

-(void)addLoginButton:(UINavigationBar *)bar
{
    BOOL isLoggedIn = [[APAccount currentAccount] isLoggedIn];
    NSString *const image = isLoggedIn ? kImageLogout : kImageLogin;
    UIBarButtonItem * bbi = [self barButtonForImage:image
                                              title:nil
                                              block:^(UIViewController *me, id button) {
                                                  [me toggleLogin:bar];
                                              }];
    
    if( ![self associatedValueForKey:kHasLoginWatcherKey] )
    {
        [self associateValue:@(YES) withKey:kHasLoginWatcherKey];
        [self registerForBroadcast:kNotifyUserLoginStatusChanged
                             block:^(UIViewController *me, APAccount *account) {
                                 [me addLoginButton:bar];
                             }];
    }
    
    [self addRightButton:bar button:bbi replaceIndex:0];
}

-(void)toggleLogin:(UINavigationBar *)bar
{
    APAccount *account = [APAccount currentAccount];
    if( account.isLoggedIn )
    {
        [account logUserOut];
        NSString *msg = NSLocalizedString(@"You have been logged out", @"Log out button");
        [APPopup msgWithParent:self.view text:msg dismissBlock:^{
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
                                    [me.presentingViewController dismissViewControllerAnimated:YES completion:^{
                                        APDismissBlock block = [me associatedValueForKey:kDismissBlockKey];
                                        if( block )
                                            block(me);
                                    }];
                                }];
    bar.topItem.leftBarButtonItem = bbBack;
    
}

-(void)navigateTo:(NSString *)vcName
{
    if( self.parentViewController )
       [self.parentViewController navigateTo:vcName];
}

-(UIViewController *)presentVC:(NSString *)vcName animated:(BOOL)animated completion:(void (^)())block
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcName];
    [self presentViewController:vc animated:animated completion:block];
    return vc;
}

-(void)showError:(NSError *)error
{
    [self showError:error dismissBlock:nil];
}

-(void)setDismissBlock:(APDismissBlock)block
{
    [self associateValue:[block copy] withKey:kDismissBlockKey];
}

-(void)showError:(NSError *)error dismissBlock:(APDismissBlock)block
{
    APAppDelegate * ad = (APAppDelegate *)([UIApplication sharedApplication].delegate);
    UIViewController * host = ad.window.rootViewController;
    if( host.presentedViewController )
        host = host.presentedViewController;
    
    if( [host isBeingDismissed] || [host isBeingPresented] )
    {
        [NSObject performBlock:^{
            [self showError:error dismissBlock:block];
        } afterDelay:0.3];
        return;
    }
    
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewError];
    if( block )
        [vc setDismissBlock:block];
    [vc setValue:error forKey:@"errorObj"];
    [host presentViewController:vc animated:YES completion:nil];
}

@end

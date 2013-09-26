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
    _map[@(button.hash)] = block;
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

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
                                block:(APMenuBlock)block;
{
    UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imgName]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(invokeMenuItem:)];
    NSMutableDictionary * _map = self.targetMap;
    _map[@(bbi.hash)] = [block copy];
    return bbi;
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
#warning Should move this to appDelegate and new Nav system
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)iOrientation {
    return (iOrientation == UIInterfaceOrientationPortrait);
}

-(void)argoPayIze
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [self setNeedsStatusBarAppearanceUpdate];
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, 320, 20 }];
        view.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:view];
        
        for( NSLayoutConstraint *lcx in self.view.constraints )
        {
            if( lcx.secondItem == self.view && lcx.firstAttribute == NSLayoutAttributeTop )
            {
                lcx.constant += 20;
                APLOG(kDebugViews, @"Shifting %@ in %@",lcx.firstItem, self);
                break;
            }
        }

    }
}

@end

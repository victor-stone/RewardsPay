//
//  UIViewController+ArgoPay.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBarButtonSize 20

typedef void (^APMenuBlock)(id,id);
typedef void (^APDismissBlock)(UIViewController* dismissing);

@interface UIViewController (ArgoPay)

-(UIBarButtonItem *)barButtonForImage:(NSString *)imgName
                                title:(NSString *)title
                                block:(APMenuBlock)block;

-(void)addHomeButton:(UINavigationBar *)bar;
-(void)addLoginButton:(UINavigationBar *)bar;
-(void)addRightButton:(UINavigationBar *)bar button:(UIBarButtonItem *)bbi;
-(void)addBackButton:(UINavigationBar *)bar;
-(void)addBackButton:(UINavigationBar *)bar title:(NSString *)title;
-(void)addSlideBackButton:(UINavigationBar *)bar;

-(void)setDismissBlock:(APDismissBlock)block;

-(void)navigateTo:(NSString *)vcName;

-(void)showError:(NSError *)error;
-(void)showError:(NSError *)error dismissBlock:(APDismissBlock)block;

-(UIViewController *)presentVC:(NSString *)vcName animated:(BOOL)animated completion:(void (^)())block;

-(void)argoPayIze;

@end

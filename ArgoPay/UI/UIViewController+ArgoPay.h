//
//  UIViewController+ArgoPay.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBarButtonSize 30

typedef void (^APMenuBlock)(id,id);


@interface UIViewController (ArgoPay)

-(UIBarButtonItem *)barButtonForImage:(NSString *)imgName
                                title:(NSString *)title
                                block:(APMenuBlock)block;

-(void)addHomeButton:(UINavigationBar *)bar;
-(void)navigateTo:(NSString *)vcName;

@end

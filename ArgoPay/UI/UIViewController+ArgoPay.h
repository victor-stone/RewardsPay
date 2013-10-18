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
-(void)adjustViewForiOS7;

@end

//
//  APPopup.h
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBGInset 12
#define kPopupInsetPadding (kBGInset + 8)

#define kErrorPopupInsetTop 8
#define kErrorPopupInsetLeft 8
#define kErrorPopupInsetBottom 24
#define kErrorPopupInsetRight 8

#import "VSPopup.h"

@interface APPopup : VSPopup
+(id)popupWithParent:(UIView *)parent text:(NSString *)text flags:(VSPopupFlags)flags;
+(id)msgWithParent:(UIView *)parent text:(NSString *)text;
+(id)errorWithParent:(UIView *)view error:(NSError *)err;
@end



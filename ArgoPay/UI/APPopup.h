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

#import "VSPopup.h"
@interface APPopup : VSPopup
+(id)popupWithParent:(UIView *)parent text:(NSString *)text flags:(VSPopupFlags)flags;
+(id)msgWithParent:(UIView *)parent text:(NSString *)text;
@end



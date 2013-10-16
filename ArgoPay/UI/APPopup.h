//
//  APPopup.h
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSPopup.h"

@interface APPopup : VSPopup
+(id)popupWithParent:(UIView *)parent text:(NSString *)text flags:(VSPopupFlags)flags;
+(id)msgWithParent:(UIView *)parent text:(NSString *)text;
+(id)msgWithParent:(UIView *)parent text:(NSString *)text dismissBlock:(VSPopupDismissBlock)dismissBlock;
+(id)errorWithParent:(UIView *)view error:(NSError *)err;
+(id)withNetActivity:(UIView *)parent; // delay: YES
+(id)withNetActivity:(UIView *)parent delay:(BOOL)delay;
@end


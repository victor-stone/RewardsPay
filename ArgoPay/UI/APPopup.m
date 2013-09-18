//
//  APPopup.m
//  ArgoPay
//
//  Created by victor on 9/18/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APPopup.h"
#import "APStrings.h"

@implementation APPopup

+(id)popupWithParent:(UIView *)parent text:(NSString *)text flags:(VSPopupFlags)flags
{
    UIImage * bg = [[UIImage imageNamed:kImagePopupBG]
                    resizableImageWithCapInsets:UIEdgeInsetsMake(kBGInset,kBGInset,kBGInset,kBGInset)
                    resizingMode:UIImageResizingModeStretch];
    
    return [[VSPopup alloc] initWithParent:parent flags:flags textOrView:text bg:bg];
}

+(id)msgWithParent:(UIView *)parent text:(NSString *)text
{
    return [self popupWithParent:parent text:text flags:kPopupCloseOnAnyTap];
}

@end
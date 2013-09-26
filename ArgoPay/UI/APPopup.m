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

APLOGRELEASE

+(id)popupWithParent:(UIView *)parent text:(NSString *)text flags:(VSPopupFlags)flags
{
    UIImage * bg = [[UIImage imageNamed:kImagePopupBG]
                    resizableImageWithCapInsets:UIEdgeInsetsMake(kBGInset,kBGInset,kBGInset,kBGInset)
                    resizingMode:UIImageResizingModeStretch];
    
    return [[APPopup alloc] initWithParent:parent flags:flags textOrView:text bg:bg];
}

+(id)withNetActivity:(UIView *)parent
{
    return [self popupWithParent:parent
                            text: NSLocalizedString(@"Contacting ArgoPay Server","popup")
                           flags:kPopupActivity];
}

+(id)msgWithParent:(UIView *)parent text:(NSString *)text
{
    return [self popupWithParent:parent text:text flags:kPopupCloseOnAnyTap];
}

+(id)errorWithParent:(UIView *)parent error:(NSError *)err
{
    UIImage * bg = [[UIImage imageNamed:kImageErrorBalloon]
                    resizableImageWithCapInsets:UIEdgeInsetsMake(kErrorPopupInsetTop,kErrorPopupInsetLeft,
                                                                 kErrorPopupInsetBottom, kErrorPopupInsetRight)
                    resizingMode:UIImageResizingModeStretch];
    
    return [[APPopup alloc] initWithParent:parent flags:kPopupCloseOnAnyTap textOrView:[err localizedDescription] bg:bg];
}

-(id)initWithParent:(UIView *)parent flags:(VSPopupFlags)flags textOrView:(id)textOrView bg:(UIImage *)background
{
    return [super initWithParent:parent flags:flags textOrView:textOrView bg:background];
}

@end
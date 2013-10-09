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
    return [[APPopup alloc] initWithParent:parent flags:flags textOrView:text];
}

+(id)withNetActivity:(UIView *)parent
{
    NSString *str = NSLocalizedString(@"Connecting...", @"popup");
    return [[APPopup alloc] initWithParent:parent flags:kPopupActivity | kPopupDelay textOrView:str];
}

+(id)msgWithParent:(UIView *)parent text:(NSString *)text
{
    return [self popupWithParent:parent text:text flags:kPopupCloseOnAnyTap];
}

+(id)msgWithParent:(UIView *)parent text:(NSString *)text dismissBlock:(VSPopupDismissBlock)dismissBlock
{
    APPopup *popup = [self popupWithParent:parent text:text flags:kPopupCloseOnAnyTap|kPopupNoAutoShow];
    [popup present:dismissBlock];
    return popup;
}

+(id)errorWithParent:(UIView *)parent error:(NSError *)err
{
    return [[APPopup alloc] initWithParent:parent flags:kPopupCloseOnAnyTap textOrView:[err localizedDescription]];
}

-(id)initWithParent:(UIView *)parent flags:(VSPopupFlags)flags textOrView:(id)textOrView
{
    return [super initWithParent:parent flags:flags textOrView:textOrView];
}

@end
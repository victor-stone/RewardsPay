//
//  VSPopup.m
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//
#define VS_POPUP_KEYS

#import <QuartzCore/QuartzCore.h>
#import "VSPopup.h"
#import "APDebug.h" // AP additions...
#import "APStrings.h"

NSString * kVSNotificationPopupDismissed = @"kVSNotificationPopupDismissed";

@implementation VSPopup {
    VSPopupDismissBlock _dismissBlock;
}

APLOGRELEASE

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithParent:(UIView *)parent
              flags:(VSPopupFlags)flags
         textOrView:(id)textOrView
                 bg:(UIImage *)background
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if( !self )
        return nil;
    
    if( (flags & kPopupCloseOnAnyTap) != 0 )
    {
        UITapGestureRecognizer * tgr;
        tgr = [[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [self dismiss];
        }];
        [self addGestureRecognizer:tgr];
    }
    
    self.alpha = 0.0;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    CGRect rc =  self.frame;
    CGRect imgFrame = CGRectInset(rc, rc.size.width * 0.25, rc.size.height * 0.3);
    
    UIView * view = nil;
    if( [textOrView isKindOfClass:[NSString class]] )
    {
        CGFloat width = imgFrame.size.width * 0.8;
        NSString * text = textOrView;
        UILabel * label = [[UILabel alloc] initWithFrame:(CGRect){ 0, 0, width, 10 }];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.text = text;
        [label sizeToFit];
        CGRect tframe = label.frame;
        CGSize sz = self.bounds.size;
        sz.width /= 2.0;
        sz.height /= 2.0;
        tframe.origin = (CGPoint){ sz.width - (width/2.0), sz.height - (tframe.size.height/2.0) };
        label.frame = tframe;
        view = label;
    }
    else
    {
        view = textOrView;
        CGSize vrc = view.frame.size;
        if( vrc.height + vrc.width == 0 )
            view.frame = CGRectInset(imgFrame, rc.size.width * 0.1, rc.size.height * 0.1 );
    }

    [self addSubview:view];
    
    UIEdgeInsets inset = background.capInsets;
    rc = view.frame;
    imgFrame  =  CGRectInset(view.frame, -((inset.left+inset.right)+kPopupInsetPadding), -((inset.top+inset.bottom)+kPopupInsetPadding));
    
    if( (flags & kPopupActivity) != 0 )
    {
        UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect aframe = activity.frame;
        aframe.origin.y = (rc.origin.y + rc.size.height) + (aframe.size.height * 2);
        aframe.origin.x = (self.bounds.size.width / 2.0) - (aframe.size.width / 2.0);
        activity.frame = aframe;
        [activity startAnimating];
        [self addSubview:activity];
        imgFrame.size.height += (aframe.size.height * 4.0);
    }
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:imgFrame];
    imgView.image = background;
    imgView.layer.shadowColor = [UIColor blackColor].CGColor;
    imgView.layer.shadowOpacity = 0.7f;
    imgView.layer.shadowOffset = CGSizeMake(14.0f, 14.0f);
    imgView.layer.shadowRadius = 5.0f;
    imgView.layer.masksToBounds = NO;
    
    [self insertSubview:imgView atIndex:0];
    
        [parent addSubview:self];
        
        if( (flags & kPopupNoAutoShow) == 0 )
            [self present];
        
    return self;
}

-(void)present
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }];
}

-(void)present:(VSPopupDismissBlock)dismissBlock
{
    _dismissBlock = dismissBlock;
    [self present];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self broadcast:kVSNotificationPopupDismissed payload:self];
        [self removeFromSuperview];
        if( _dismissBlock )
        {
            _dismissBlock();
            _dismissBlock = nil;
        }
    }];
}
@end

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
    CGFloat _animationSpeed;
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
    CGFloat bgAlpha = ( (flags & kPopupActivity) != 0 ) ? 0.2 : 0.8;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:bgAlpha];
    
    CGFloat x,y,w,h;
    CGRect temp;
    
    CGRect WHOLE_SCREEN =  self.frame;
    
    w = WHOLE_SCREEN.size.width * 0.65;
    x = w / 4.0;
    y = WHOLE_SCREEN.size.height * 0.23;
    h = 60.0; // random, set later;
    
    UIView * backView = [[UIView alloc] initWithFrame:(CGRect){ {x,y}, {w,h} }];
    backView.layer.cornerRadius = 8.0;
    backView.layer.masksToBounds = NO;
    backView.backgroundColor = [UIColor orangeColor];
    [self addSubview:backView];
    
    UIView *innerView = [[UIView alloc] initWithFrame:(CGRect){ {3.0, 3.0}, { 20,20} }]; // w,h random
    innerView.backgroundColor = [UIColor whiteColor];
    innerView.layer.masksToBounds = YES;
    innerView.layer.cornerRadius = 8.0;
    [backView addSubview:innerView];
    
    backView.layer.shadowColor = [UIColor blackColor].CGColor;
    backView.layer.shadowOpacity = 1.0;
    backView.layer.shadowOffset = CGSizeMake(8.0, 8.0);
    backView.layer.shadowRadius = 2.0;

    UIView * view = nil;
    CGPoint org = (CGPoint){ kPopupInsetPadding, kPopupInsetPadding };
    if( [textOrView isKindOfClass:[NSString class]] )
    {
        NSString * text = textOrView;
        UILabel * label = [[UILabel alloc] initWithFrame:(CGRect){ org, {w - kPopupGutter, 10} }];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor =  [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.text = text;
        [label sizeToFit];
        
        view = label;
        h = label.frame.size.height + kPopupGutter;
    }
    else
    {
        view = textOrView;
        CGSize sz = view.frame.size;
        if( (sz.height == 0) || (sz.width == 0) )
            sz = (CGSize){ w - kPopupGutter, h - kPopupGutter };
        view.frame = (CGRect){ org, sz };
    }

    [innerView addSubview:view];
    
    UIActivityIndicatorView * activity = nil;
    if( (flags & kPopupActivity) != 0 )
    {
        activity = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        activity.backgroundColor = [UIColor whiteColor];
        CGRect aframe = activity.frame;
        temp = view.frame;
        aframe.origin.y = temp.origin.y + temp.size.height + kPopupGutter;
        aframe.origin.x = (w / 2.0) - (aframe.size.width / 2.0);
        activity.frame = aframe;
        [activity startAnimating];
        [innerView addSubview:activity];
        h += (kPopupGutter + aframe.size.height + kPopupGutter);
        _animationSpeed = 0.35;
    }
    else
    {
        h += kPopupHeightFudge;
        _animationSpeed = 0.6;
    }

    backView.frame = (CGRect){ {x,y}, {w,h} };
    innerView.frame = (CGRect){ {kPopupBorderSize,kPopupBorderSize}, {w-kPopupBorderPadding,h-kPopupBorderPadding} };
    
    [parent addSubview:self];
    
    if( (flags & kPopupNoAutoShow) == 0 )
        [self present];
    
    return self;
}

-(void)present
{
    [UIView animateWithDuration:_animationSpeed animations:^{
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
    [UIView animateWithDuration:_animationSpeed animations:^{
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

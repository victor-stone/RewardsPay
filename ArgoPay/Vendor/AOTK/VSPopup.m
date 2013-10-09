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
#if DEBUG
#import "APDebug.h" // AP additions...
#import "APStrings.h"
#endif
NSString * kVSNotificationPopupDismissed = @"kVSNotificationPopupDismissed";

@interface VSPopupBackView : UIView {
    bool _doneOnce;
}
@end
@implementation VSPopupBackView

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)theKey {

    CATransition *theAnimation = nil;
    
    if (!_doneOnce && [theKey isEqualToString:kCAOnOrderIn] ) {
        
        theAnimation = [[CATransition alloc] init];
        theAnimation.duration = 0.2;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        theAnimation.type = kCATransitionPush;
        theAnimation.subtype = kCATransitionFromRight;
        _doneOnce = YES;
    }
    return theAnimation;
}



@end
@implementation VSPopup {
    VSPopupDismissBlock _dismissBlock;
    CGFloat             _animationSpeed;
    __weak UIView *     _contentView;
    UIView *            _delayedView;
    id                  _cancelBlock;
}

#if DEBUG
APLOGRELEASE
#endif

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
    
    UIView * contentView = [[VSPopupBackView alloc] initWithFrame:(CGRect){ {x,y}, {w,h} }];
    contentView.backgroundColor = [UIColor whiteColor];
    CALayer *layer = contentView.layer;

    layer.cornerRadius = 8.0;
    layer.masksToBounds = NO;
    
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    layer.shadowOffset = CGSizeMake(8.0, 8.0);
    layer.shadowRadius = 2.0;
    layer.borderColor = [UIColor orangeColor].CGColor;
    layer.borderWidth = 2.0;

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

    [contentView addSubview:view];
    
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
        [contentView addSubview:activity];
        h += (kPopupGutter + aframe.size.height + kPopupGutter);
    }
    else
    {
        h += kPopupHeightFudge;
    }

    _animationSpeed = kPopupFadeSpeed;

    contentView.frame = (CGRect){ {x,y}, {w,h} };
   
    // Pieces not quite fitting together here
    // what if delay AND noShow are both on?
    
    if( flags & kPopupDelay )
    {
        _delayedView = contentView;
        _cancelBlock = [NSObject performBlock:^{
            [self doCancel:NO];
        } afterDelay:kPopupDelayTime];
    }
    else
    {
        _contentView = contentView;
        [self addSubview:contentView];
    }
    
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

-(void)doCancel:(BOOL)cancel
{
    if( _cancelBlock )
    {
        [NSObject cancelBlock:_cancelBlock];
        _cancelBlock = nil;
    }
    
    if( cancel )
    {
        _delayedView = nil;
        [self _dismiss];
    }
    else
    {
        [self addSubview:_delayedView];
        _delayedView = nil;
    }
}

-(void)_dismiss
{
    CGRect rc;
    
    if( _contentView )
    {
        rc = _contentView.frame;
        rc.origin.x = -300;
    }
    
    [UIView animateWithDuration:(_animationSpeed * 0.5) animations:^{
        self.alpha = 0.0;
        if( _contentView )
            _contentView.frame = rc;
        
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

-(void)dismiss
{
    [self doCancel:YES];
}
@end

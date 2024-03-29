//
//  VSPopup.h
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import <UIKit/UIKit.h>


#ifndef VS_POPUP_KEYS
extern NSString * kVSNotificationPopupDismissed;
#endif

#ifndef kPopupInsetPadding
#define kPopupInsetPadding 20
#endif

#ifndef kPopupBorderSize
#define kPopupBorderSize 3
#endif

#ifndef kPopupHeightFudge
#define kPopupHeightFudge 10
#endif

#define kPopupGutter        (kPopupInsetPadding*2)
#define kPopupBorderPadding (kPopupBorderSize*2)

#ifndef kPopupDelayTime
#define kPopupDelayTime 1.7
#endif

#ifndef kPopupFadeSpeed
#define kPopupFadeSpeed 0.9
#endif

typedef void (^VSPopupDismissBlock)();

typedef enum _VSPopupFlags {
    kPopupDefaults = 0,
    kPopupCloseOnAnyTap = 1,
    kPopupCancelButton = 1 << 1,
    kPopupActivity = 1 << 2,
    kPopupNoAutoShow = 1 << 3,
    kPopupAnimateIn = 1 << 4,
    kPopupAnimateOut = 1 << 5,
    kPopupAnimate = (kPopupAnimateIn | kPopupAnimateOut),
    kPopupDelay = 1 << 6
} VSPopupFlags;

@interface VSPopup : UIView

@property (weak,nonatomic) UIActivityIndicatorView *activity;

-(id)initWithParent:(UIView *)parent
              flags:(VSPopupFlags)flags
         textOrView:(id)textOrView;

-(void)present;
-(void)present:(VSPopupDismissBlock)dismissBlock;
-(void)dismiss;
@end


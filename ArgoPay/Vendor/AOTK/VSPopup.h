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
#define kPopupInsetPadding 10
#endif

typedef enum _VSPopupFlags {
    kPopupDefaults = 0,
    kPopupCloseOnAnyTap = 1,
    kPopupCancelButton = 1 << 1,
    kPopupActivity = 1 << 2,
    kPopupNoAutoShow = 1 << 3
} VSPopupFlags;

@interface VSPopup : UIView

@property (weak,nonatomic) UIActivityIndicatorView *activity;

-(id)initWithParent:(UIView *)parent
              flags:(VSPopupFlags)flags
         textOrView:(id)textOrView
                 bg:(UIImage *)background;

-(void)present;
-(void)dismiss;
@end

//
//  UIApplication+ArgoPay.m
//  ArgoPay
//
//  Created by victor on 10/29/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <objc/runtime.h>
#import "APStrings.h"

#define INACTIVITY_TIMEOUT 60*4

@implementation UIApplication (ArgoPayTimeOut)

static void * kInactivityTimerKey = &kInactivityTimerKey;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self ap_swizzle];
        }
    });
}

+(void)ap_swizzle
{
    SEL se   = @selector(sendEvent:);
    SEL apse = @selector(apSendEvent:);
    method_exchangeImplementations(class_getInstanceMethod(self, se), class_getInstanceMethod(self, apse));
}

-(void)apSendEvent:(UIEvent *)event
{
    NSTimer * timer = [self associatedValueForKey:kInactivityTimerKey];
    if( timer )
        [timer invalidate];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:INACTIVITY_TIMEOUT
                                            repeats:NO
                                              block:^(NSTimeInterval time) {
                                                  [self broadcast:kNotifyInactivityTimeOut payload:self];
                                              }];
    
    [self associateValue:timer withKey:kInactivityTimerKey];

    [self apSendEvent:event];
}

@end

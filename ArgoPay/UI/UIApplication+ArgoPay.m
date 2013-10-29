//
//  UIApplication+ArgoPay.m
//  ArgoPay
//
//  Created by victor on 10/29/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"

#define INACTIVITY_TIMEOUT 60*4

@interface ArgoPayApplication : UIApplication {
    NSTimer * _inactivityTimer;
}
@end

@implementation ArgoPayApplication

-(void)sendEvent:(UIEvent *)event
{
    if( _inactivityTimer )
        [_inactivityTimer invalidate];
    
    _inactivityTimer = [NSTimer scheduledTimerWithTimeInterval:INACTIVITY_TIMEOUT
                                            repeats:NO
                                              block:^(NSTimeInterval time) {
                                                  [self broadcast:kNotifyInactivityTimeOut payload:self];
                                              }];
    
    [super sendEvent:event];
}
@end

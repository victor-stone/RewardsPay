//
//  VSConnectivity.m
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#define VS_CONNECTIVITY_KEYS

#import "VSConnectivity.h"

NSString * kVSNotificationConnectionTypeChanged = @"kVSNotificationConnectionTypeChanged";

@implementation VSConnectivity

/**
 *  Standard callback for noting when device has changed reachability status
 *
 *  @see SCNetworkReachabilitySetCallback
 */
void connectivity_callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    NSLog(@"Info: %p", info);
    
    VSConnectivity * conn = (__bridge VSConnectivity *)info;
    
	if ((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired) && !(flags & kSCNetworkReachabilityFlagsIsWWAN))
	{
        conn->_connectionType = kConnectionWifi;
	}
	else if ((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired) && (flags & kSCNetworkReachabilityFlagsIsWWAN))
	{
        conn->_connectionType = kConnectionCelluar;
	}
	else
	{
		conn->_connectionType = kConnectionNone;
	}
    
    [conn broadcast:kVSNotificationConnectionTypeChanged payload:conn];
}

-(id)initWithHost:(NSString *)host
{
    self = [super init];
    if( self )
    {
        const char *host_name = [host UTF8String];
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        
        if (reachability)
        {
            SCNetworkReachabilityContext ctx = { 0 };
            ctx.info = (__bridge void *)self;
            NSLog(@"Self ptr: %p", ctx.info);
            Boolean success = SCNetworkReachabilitySetCallback(reachability, connectivity_callback, &ctx);
            
            if (success)
            {
                NSLog(@"Thread: %@", [NSThread currentThread]);
                
                SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            }
        }
    }
    return self;
}
@end

@implementation VSNetworkProgress
@end

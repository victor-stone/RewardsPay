//
//  APAppDelegate.h
//  ArgoPay
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSConnectivity.h"

@interface APMasterViewController : UIViewController
@end

@interface APAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(APMasterViewController *)masterVC;

/**
 *  Maintains the current state of the network connectivity.
 *
 *  It is the payload to the kVSNotificationConnectionTypeChanged broadcast event.
 *
 *  @warning This property is volatile, it is completely refereshed each time the app
 *           comes into the foreground and activates. Do NOT hold a reference to it.
 *
 */
@property (strong, nonatomic) VSConnectivity *connectivity;

@end

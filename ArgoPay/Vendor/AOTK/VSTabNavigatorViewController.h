//
//  VSTabNavigatorViewController.h
//  ArgoPay
//
//  Created by victor on 10/14/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "VSTabNavigator.h"

#define kNavigatorEmbedSegue @"kNavigatorEmbedSegue"

@interface VSTabNavigatorViewController : UIViewController<VSTabNavigatorDelegate>
@property (nonatomic,weak) IBOutlet VSTabNavigator *tabNavigator;
@property (nonatomic,weak)          VSNavigationViewController  *navigationViewController;
@end

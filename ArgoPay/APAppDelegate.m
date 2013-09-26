//
//  APAppDelegate.m
//  ArgoPay
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APAppDelegate.h"
#import "APStrings.h"

@implementation APAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerUserDefaults];
    return YES;
}

-(NSDictionary *)factoryUserDefaultSettings
{
    return @{
             kSettingUserLoginName: @"",
             kSettingUserLoginPassword: @"",
             kSettingSlidingCameraView: @(YES)
#ifdef DEBUG
             , kSettingDebugNetworkStubbed: @"argotest",
             kSettingDebugNetworkDelay: @("1.5"),
             kSettingDebugRejectLogin: @(NO),
             kSettingUserArgoPoints: @(230),
             kSettingDebugNetworkSimulatedFail: @(NO),
             kSettingDebugNetworkSSL: @(NO)
#endif
             };
}

-(void)registerUserDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self factoryUserDefaultSettings]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.connectivity = [[VSConnectivity alloc] init];    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

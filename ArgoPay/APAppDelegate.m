//
//  APAppDelegate.m
//  ArgoPay
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APAppDelegate.h"
#import "APStrings.h"
#import "IASKSettingsReader.h"
#import "APAccount.h"
#import "APPopup.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapsKey.h"
#import "APLocation.h"

@implementation APMasterViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [APPopup withNetActivity:self.view];
}

@end


@implementation APAppDelegate {
    id _notifyObserver;
    bool _showingNotConnectedView;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerUserDefaults];
    [self registerForNotifications];
    
    _connectivity = [[VSConnectivity alloc] init];
    
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    // Prime the location service
    APLocation * location = [APLocation sharedInstance];
    [location currentLocation:^{
        //
    } gotLocation:^(CLLocationCoordinate2D loc) {
        [location stop];
    }];
    // This has to happen here to prime the 'currentAccount' object
    // Otherwise calls to +currentAccount will return nil
    [self attemptLogin];
    return YES;
}

-(APMasterViewController *)masterVC
{
    return (APMasterViewController *)_window.rootViewController;
}

+(APMasterViewController *)masterVC
{
    return [((APAppDelegate *)[UIApplication sharedApplication].delegate) masterVC];
}

-(void)attemptLogin
{
    [APAccount login:nil password:nil block:^(id data, NSError *err) {
        UIViewController *initial = _window.rootViewController;
        if( err )
        {
            if( !((err.code == kAPERROR_MISSINGLOGINFIELDS) && (err.domain == kAPMobileErrorDomain)) )
            {
                [initial showError:err dismissBlock:^(UIViewController *dismissing) {
                    [NSObject performBlock:^{
                        [self attemptLogin];
                    } afterDelay:0.3];
                }];
                return;
            }
        }
        UIViewController *home = [initial.storyboard instantiateViewControllerWithIdentifier:kViewMain];
        _window.rootViewController = home;
    }];
}

-(void)registerForNotifications
{
    [self registerForBroadcast:kVSNotificationConnectionTypeChanged
                         block:^(APAppDelegate *me, VSConnectivity *connectivity)
    {
        if( connectivity.connectionType == kConnectionNone )
        {
            [NSObject performBlock:^{
                [me notConnectedToNework];
            } afterDelay:0.2];
        }
        else
        {
            if( _showingNotConnectedView )
            {
                [_window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
    
    _notifyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kIASKAppSettingChanged
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
    {
        [self broadcast:kNotifyUserSettingChanged payload:note.userInfo];
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_notifyObserver];
}

-(void)notConnectedToNework
{
    APError *error = [APError errorWithCode:kAPERROR_NONETCONNECTION];
    _showingNotConnectedView = true;
    [_window.rootViewController showError:error];
}

-(NSDictionary *)factoryUserDefaultSettings
{
    return @{
             kSettingUserLoginName: @"",
             kSettingUserLoginPassword: @"",
             kSettingSlidingCameraView: @(YES)
#ifdef DEBUG
             ,
             kSettingDebugNetworkStubbed: @"file",
             kSettingDebugLocalhostAddr: @"testingargo.192.168.1.3.xip.io",
             kSettingDebugStrictJSON: @(NO),
             kSettingDebugNetworkDelay: @"1.0",
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
    [[APLocation sharedInstance] stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[APLocation sharedInstance] stop];
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

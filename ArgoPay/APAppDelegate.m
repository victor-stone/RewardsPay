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
#import "VSConnectivity.h"
#import "Reachability.h"

typedef enum _APStartupState {
    kStartupStateExecting = 1,
    kStartupStateDone = 2
} APStartupState;

@interface APConcurrentStartupOperation : NSOperation
-(id)initWithAppDelegate:(APAppDelegate *)delegate;
@end

@interface APWaitForNetwork : APConcurrentStartupOperation
@end

@interface APWaitForLocationService : APConcurrentStartupOperation
@end

@interface APWaitForLogin : APConcurrentStartupOperation
@end

@interface APStartMainApp : NSOperation
-(id)initWithAppDelegate:(APAppDelegate *)delegate;
@end

@interface APStartupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *message;
@end


@implementation APStartupViewController {
    id _notifyObserver;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self argoPayIze];
    [_activity startAnimating];
    __weak APStartupViewController *me = self;
    _notifyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification
                                                                        object:nil
                                                                         queue:nil
                                                                    usingBlock:^(NSNotification *note)
                       {
                           
                           Reachability *reachability = note.object;
                           if( reachability.currentReachabilityStatus == NotReachable )
                           {
                               NSString * msg = NSLocalizedString(@"Your phone doesn't seem to be connected to the Internet. Please connect in Settings and then return to ArgoPay.", @"startup");
                               me.message.text = msg;
                           }
                       }];
}

@end


@interface APAppDelegate ()
@end

@implementation APAppDelegate {
    id _notifyObserver;
    BOOL _showingErrorScreen;
    NSOperationQueue * _startupQueue;
    Reachability *_reachability;
    BOOL _doneLoading;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearances];
    [self registerUserDefaults];
    [self registerForNotifications];
    
    _startupQueue = [[NSOperationQueue alloc] init];
    _startupQueue.name = @"ArgoPay startup queue";
    
    NSOperation * op1 = [[APWaitForNetwork alloc] initWithAppDelegate:self];
    NSOperation * op2 = [[APWaitForLocationService alloc] initWithAppDelegate:self];
    NSOperation * op3 = [[APWaitForLogin alloc] initWithAppDelegate:self];
    NSOperation * op4 = [[APStartMainApp alloc] initWithAppDelegate:self];
    
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    [op4 addDependency:op3];
    
    [_startupQueue addOperations:@[op1,op2,op3,op4] waitUntilFinished:NO];

    _reachability = [Reachability reachabilityWithHostName:@VS_CONNECTIVITY_HOST_NAME];
    [_reachability startNotifier];
    
    return YES;
}

-(void)setLoadingMessage:(NSString *)msg
{
    if( [_window.rootViewController isKindOfClass:[APStartupViewController class]] )
    {
        APStartupViewController *vc = (APStartupViewController *)_window.rootViewController;
        [NSObject performBlock:^{
            vc.message.text = msg;
        } afterDelay:0.1];
    }
}

-(void)setupAppearances
{
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor], UITextAttributeTextColor,
          [UIColor blackColor], UITextAttributeTextShadowColor,
          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
          nil]];
    }
     */
}

-(void)showMainAppWindow
{
    if( [NSThread currentThread] != [NSThread mainThread] )
    {
        [self performSelectorOnMainThread:@selector(_showMainAppWindow) withObject:nil waitUntilDone:YES];
    }
    else
    {
        [self _showMainAppWindow];
    }
}

-(void)_showMainAppWindow
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingUserFirstInvoke];
    [_startupQueue cancelAllOperations];
    _startupQueue = nil;
    UIViewController *initial = _window.rootViewController;
    UIViewController *home = [initial.storyboard instantiateViewControllerWithIdentifier:kViewMain];
    _window.rootViewController = home;
    _doneLoading = YES;
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
            if( _showingErrorScreen )
            {
                [_window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
    
    // Convert IASK notification center events to self:registerForBroadcast
    // to normalize different styles
    
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
    _showingErrorScreen = true;
    [_window.rootViewController showError:error];
}

-(NSDictionary *)factoryUserDefaultSettings
{
    return @{
             kSettingSlidingCameraView: @(YES),
             kSettingUserFirstInvoke: @(YES),
             kSettingUserUniqueID: [[NSProcessInfo processInfo] globallyUniqueString],
             kSettingSystemBuildNumber: [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"],
             kSettingFrequentGPS: @(YES)
             
#ifdef ALLOW_DEBUG_SETTINGS
             ,kSettingDebugNetworkStubbed: @"file"
             ,kSettingDebugLocalhostAddr: @"testingargo.192.168.1.2.xip.io"
#endif
             };
}

-(void)registerUserDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self factoryUserDefaultSettings]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain
    // types of temporary interruptions (such as an incoming phone call or SMS message) or when the
    // user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame
    // rates. Games should use this method to pause the game.
    [[APLocation sharedInstance] stopService];
    [_reachability stopNotifier];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application state information to restore your application to its current state in case
    // it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
    [[APLocation sharedInstance] stopService];
    [_reachability stopNotifier];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can
    // undo many of the changes made on entering the background.
    [[APLocation sharedInstance] startService];
    [_reachability startNotifier];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application
    // was inactive. If the application was previously in the background, optionally
    // refresh the user interface.
    if( _doneLoading  )
        [[APLocation sharedInstance] startService];
    [_reachability startNotifier];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

@implementation APConcurrentStartupOperation {
@protected
    APStartupState _state;
    id _notifyObserver;
    __weak APAppDelegate *_appDelegate;
    id _delayedMessageBlock;
}
    
-(id)initWithAppDelegate:(APAppDelegate *)appDelegate
{
    if( (self = [super init]) == nil )
        return nil;
    
    _appDelegate = appDelegate;
    return self;
}

-(BOOL)isExecuting
{
    return _state == kStartupStateExecting;
}

- (BOOL)isFinished
{
    return _state == kStartupStateDone;
}

- (BOOL)isConcurrent
{
    return YES;
}

-(void)displayDelayedMessage:(NSString *)msg
{
    __weak APConcurrentStartupOperation * me = self;
    _delayedMessageBlock = [NSObject performBlock:^{
        [me deliverMessage:msg];
    } afterDelay:3.0];
}

-(void)deliverMessage:(NSString *)msg
{
    [_appDelegate setLoadingMessage:msg];
    _delayedMessageBlock = nil;
}

-(void)dealloc
{
    if( _delayedMessageBlock )
    {
        [NSObject cancelBlock:_delayedMessageBlock];
        _delayedMessageBlock = nil;
    }
    
    if( _notifyObserver )
        [[NSNotificationCenter defaultCenter] removeObserver:_notifyObserver];
    
    _notifyObserver = nil;
    
    APLOG(kDebugStartup, @"released: %@",self);
    APLOG(kDebugLifetime, @"released: %@", self);
}

-(void)iAmStarting
{
    [self willChangeValueForKey:@"isExecuting"];
    _state = kStartupStateExecting;
    [self didChangeValueForKey:@"isExecuting"];
    APLOG(kDebugStartup, @"Starting: %@", self);
}

-(void)iAmDone
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _state = kStartupStateDone;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self cancel];
    APLOG(kDebugStartup, @"Ended: %@", self);
}
@end

@implementation APWaitForNetwork

-(void)start
{
    [self iAmStarting];
    
    [self displayDelayedMessage:NSLocalizedString(@"Connecting to Internet...",@"startup")];
    
    __weak APWaitForNetwork * me = self;
    
    _notifyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification
                                                                        object:nil
                                                                         queue:nil
                                                                    usingBlock:^(NSNotification *note)
                       {
                           Reachability *reachability = note.object;
                           APLOG(kDebugStartup, @"Got connection type: %d", reachability.currentReachabilityStatus);
                           if( reachability.currentReachabilityStatus != NotReachable )
                           {
                               [me iAmDone];
                           }
                       }];
    
}
@end

@implementation APWaitForLocationService
#define kLocationAttemptDelay 4.0

-(void)start
{
    [self iAmStarting];
    
    [self displayDelayedMessage:NSLocalizedString(@"Waiting for location information...",@"startup")];
    
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    APLocation *location = [APLocation sharedInstance];
    [location currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [_appDelegate setLoadingMessage:error.localizedDescription];
            APLOG(kDebugStartup, @"Operation location failed, retrying",0);
            return YES;
        }

        APLOG(kDebugStartup, @"Got location: %G, %G", loc.longitude, loc.latitude);
        [self iAmDone];
        return NO;
    }];
    
}
@end

@implementation APWaitForLogin
-(void)main
{
    [self iAmStarting];
    
    [self displayDelayedMessage:NSLocalizedString(@"Attempting to log in...",@"startup")];
    
    [APAccount login:nil password:nil block:^(id data, NSError *err) {
        if( err && ( !((err.code == kAPERROR_MISSINGLOGINFIELDS) && (err.domain == kAPMobileErrorDomain)) ) )
        {
            [_appDelegate setLoadingMessage:err.localizedDescription];
        }
        //else
        {
            [self iAmDone];
        }
    }];
}
@end

@implementation APStartMainApp {
    APAppDelegate *_appDelegate;
}

-(id)initWithAppDelegate:(APAppDelegate *)appDelegate
{
    if( (self = [super init]) == nil )
        return nil;
    
    _appDelegate = appDelegate;
    return self;
}

-(void)dealloc
{
    APLOG(kDebugStartup, @"released: %@",self);
    APLOG(kDebugLifetime, @"released: %@", self);
}

-(void)main
{
    APLOG(kDebugStartup, @"Starting: %@", self);
    [self cancel];
    [_appDelegate showMainAppWindow];
}

@end


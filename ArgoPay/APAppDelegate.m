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
#import "VSTabNavigator.h"

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

@interface APAppDelegate ()
@end

@implementation APAppDelegate {
    id                 _notifyObserver;
    NSOperationQueue * _startupQueue;
    BOOL               _doneLoading;
@package
    __weak UIViewController * _errorView;
    Reachability *      _reachability;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearances:application];
    [self registerUserDefaults];
    [self registerForNotifications];
    
    if( launchOptions[@"logStartup"] != nil )
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kDebugStartup];
    
    _startupQueue = [NSOperationQueue mainQueue];
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

-(void)showError:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(_showError:) withObject:error waitUntilDone:YES];
}

-(void)_showError:(NSError *)error
{
    if( _errorView )
    {
        // what? stuff error into that window?
        [_errorView setValue:error forKey:@"errorObj"];
        return;
    }
    
    UIViewController * host = _window.rootViewController;
    if( host.presentedViewController )
        host = host.presentedViewController;
    
    if( [host isBeingDismissed] || [host isBeingPresented] )
    {
        [NSObject performBlock:^{
            [self _showError:error];
        } afterDelay:0.2];
        return;
    }
    
    _errorView = [_window.rootViewController.storyboard instantiateViewControllerWithIdentifier:kViewError];
    [_errorView setValue:error forKey:@"errorObj"];
    [host presentViewController:_errorView animated:YES completion:nil];
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

-(void)setupAppearances:(UIApplication *)application
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];

        // http://stackoverflow.com/questions/19029833/ios-7-navigation-bar-text-and-arrow-color/19029973#19029973

        [[UINavigationBar appearance] setTitleTextAttributes:
         @{ NSForegroundColorAttributeName: [UIColor whiteColor]
            }];
        [[UINavigationBar appearance] setBarTintColor:[UIColor orangeColor]];
     }
}

-(void)showMainAppWindow
{
    APAccount * account = [APAccount currentAccount];
    NSString *viewName = account.isLoggedIn ? kViewMain : kViewLogin;
    [self performSelectorOnMainThread:@selector(_changeRootWindow:) withObject:viewName waitUntilDone:YES];
}

-(void)_changeRootWindow:(NSString *)viewName
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingUserFirstInvoke];
    [_startupQueue cancelAllOperations];
    _startupQueue = nil;
    UIViewController *initial = _window.rootViewController;
    UIViewController *home = [initial.storyboard instantiateViewControllerWithIdentifier:viewName];
    _window.rootViewController = home;
    _doneLoading = YES;
}

-(void)registerForNotifications
{
    [self registerForBroadcast:kNotifySystemError
                         block:^(APAppDelegate *me, NSError *error)
    {
        [me showError:error];
    }];
    
    [self registerForBroadcast:kNotifyErrorViewClosed
                         block:^(APAppDelegate *me, UIViewController *errorView)
     {
         me->_errorView = nil;
     }];
    
    [self registerForBroadcast:kVSNotificationConnectionTypeChanged
                         block:^(APAppDelegate *me, VSConnectivity *connectivity)
    {
        if( connectivity.connectionType == kConnectionNone )
        {
            APError *error = [APError errorWithCode:kAPERROR_NONETCONNECTION];
            [me showError:error];
        }
    }];
    
    [self registerForBroadcast:kNotifyUserLoginStatus
                         block:^(APAppDelegate *me, APAccount *account)
     {
        if( me->_doneLoading )
            [me showMainAppWindow];
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

-(NSDictionary *)factoryUserDefaultSettings
{
    return @{
             kSettingSlidingCameraView: @(YES),
             kSettingUserFirstInvoke: @(YES),
             kSettingUserUniqueID: [[NSProcessInfo processInfo] globallyUniqueString],
             kSettingSystemBuildNumber: [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"],
             kSettingFrequentGPS: @(YES),
             kSettingViewAsKilometer: @(YES),
             kSettingUserUseGoogleMaps: @(YES)
             
#ifdef ALLOW_DEBUG_SETTINGS
             ,kSettingDebugNetworkStubbed: @"file"
             ,kSettingDebugLocalhostAddr: @"testingargo.192.168.1.2.xip.io"
#endif
             };
}

-(void)registerUserDefaults
{
    NSDictionary * defaults = [self factoryUserDefaultSettings];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
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
    if( _doneLoading )
    {
        [[APLocation sharedInstance] startService];
        [_reachability startNotifier];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application
    // was inactive. If the application was previously in the background, optionally
    // refresh the user interface.
    if( _doneLoading  )
    {
        [[APLocation sharedInstance] startService];
        [_reachability startNotifier];
    }
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
    
    if( _appDelegate->_reachability && (_appDelegate->_reachability.currentReachabilityStatus != NotReachable) )
    {
        [self iAmDone];
    }
    else
    {
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
}
@end

@implementation APWaitForLocationService
#define kLocationAttemptDelay 4.0

-(void)tryToGetLocation
{
    APLocation *location = [APLocation sharedInstance];
    [location currentLocation:^(CLLocationCoordinate2D loc) {
        APLOG(kDebugStartup, @"Got location: %G, %G", loc.longitude, loc.latitude);
        [self iAmDone];
    }];
    
    if( !self.isCancelled && !self.isFinished )
    {
        [NSObject performBlock:^{
            [self tryToGetLocation];
        } afterDelay:0.5];
    }
}
-(void)start
{
    [self iAmStarting];
    
    [self displayDelayedMessage:NSLocalizedString(@"Waiting for location information...",@"startup")];
    
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    [self tryToGetLocation];
}
@end

@implementation APWaitForLogin
-(void)main
{
    [self iAmStarting];
    
    [self displayDelayedMessage:NSLocalizedString(@"Attempting to log in...",@"startup")];
    
    [APAccount attempLoginWithDefaults:^(id data) {
        [self iAmDone];
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


@implementation APStartupViewController {
    id _notifyObserver;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
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

-(IBAction)unwindFromError:(UIStoryboardSegue *)segue
{
    [self broadcast:kNotifyErrorViewClosed payload:self];
}

@end


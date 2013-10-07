//
//  APLocation.m
//  ArgoPay
//
//  Created by victor on 9/30/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APLocation.h"
#import "APStrings.h"

#define kLocationGoesStaleAfterSeconds 60000
#define kLocationTimeOut 20.0

@implementation APLocation {
    CLLocation *_lastLocation;
    bool _running;
    CLLocationManager * _manager;
    NSMutableArray *_waitingBlocks;
    CLAuthorizationStatus _currentStatus;
    BOOL _useSignificant;
    id _timeOutBlock;
}

static APLocation *__sharedLocation;

+(id)sharedInstance
{
    @synchronized(self) {
        if( !__sharedLocation )
            __sharedLocation = [APLocation new];
    }
    return __sharedLocation;
}

+(BOOL)appIsAuthorized
{
    if ( [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized))
        return YES;
    return NO;
}

-(id)init
{
    if( (self = [super init]) == nil )
        return nil;
    
    _waitingBlocks = [NSMutableArray new];
    _useSignificant = ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingFrequentGPS];
    
    [self registerForBroadcast:kNotifyUserSettingChanged block:^(APLocation *me, NSDictionary *settings) {
        for( NSString *key in settings )
        {
            if( [key isEqualToString:kSettingFrequentGPS] )
            {
                BOOL newSetting = ![settings[key] boolValue];
                if( newSetting != _useSignificant )
                {
                    APLOG(kDebugLocation, @"User set _useSignificant to: %d", newSetting);
                    _useSignificant = newSetting;
                    if( me->_running )
                    {
                        [me stopService];
                        _manager = nil;
                        [me startService];
                    }
                }
            }
        }
    }];
    return self;
}

-(void)setLocationTimeOut
{
    [self cancelTimeOut];
    if( 0 ) // && (_currentStatus == kCLAuthorizationStatusNotDetermined) || !_useSignificant )
    {
        APLOG(kDebugLocation, @"Setting timer",0);
        __weak APLocation *me = self;
        CLLocationManager *manager = _manager;
        _timeOutBlock = [NSObject performBlock:^{
            APLOG(kDebugLocation, @"Timed out!",0);
            [me locationManager:manager didFailWithError:[APError errorWithCode:kAPERROR_GPSTIMEOUT]];
        } afterDelay:kLocationTimeOut];
    }
}

-(void)cancelTimeOut
{
    if( _timeOutBlock )
    {
        APLOG(kDebugLocation, @"cancelling timer", 0);
        [NSObject cancelBlock:_timeOutBlock];
        _timeOutBlock = nil;
    }
}

-(void)startService
{
    [self performSelectorOnMainThread:@selector(_startService) withObject:nil waitUntilDone:YES];
}

-(void)_startService
{
    if( !_manager )
    {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        APLOG(kDebugLocation, @"Initializing manager", 0);
    }
    
    _lastLocation = nil;
    APLOG(kDebugLocation, @"Starting updates (significant: %d)", _useSignificant);
    if( _useSignificant )
        [_manager startMonitoringSignificantLocationChanges];
    else
        [_manager startUpdatingLocation];
    _running = true;
    [self setLocationTimeOut];
}

-(void)stopService
{
    if( _running )
    {
        APLOG(kDebugLocation, @"Stopping manager", 0);
        _running = false;
        if( _useSignificant )
            [_manager stopMonitoringSignificantLocationChanges];
        else
            [_manager stopUpdatingLocation];
    }
}

-(void)currentLocation:(APLocationBlock)gotBlock
{

    if( _lastLocation )
    {
        CLLocationCoordinate2D coord = _lastLocation.coordinate;
        APLOG(kDebugLocation, @"Calling(1) with: lat:%f long:%f", coord.latitude, coord.longitude);
        gotBlock(coord,nil);
    }
    else
    {
        if( _currentStatus == kCLAuthorizationStatusAuthorized || _currentStatus == kCLAuthorizationStatusNotDetermined )
        {
            APLOG(kDebugLocation, @"Queing request with status: %d", _currentStatus);
            [_waitingBlocks addObject:[gotBlock copy]];
            if( !_running )
                [self startService];
        }
        else
        {
            APLOG(kDebugLocation, @"request dropped status: %d", _currentStatus);
            APError *error = [APError errorWithCode:kAPERROR_NOGPS];
            if( gotBlock((CLLocationCoordinate2D){0,0},error) )
                [_waitingBlocks addObject:[gotBlock copy]];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    APLOG(kDebugLocation,@"Status change in delegate to: %d",status);
    _currentStatus = status;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];

    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    APLOG(kDebugLocation, @"Got: lat:%f long:%f time:%@ recency: %G",
            location.coordinate.latitude,
            location.coordinate.longitude,
            eventDate,
            howRecent);
    
    if ( !_lastLocation || (abs(howRecent) < kLocationGoesStaleAfterSeconds) )
    {
        _lastLocation = location;
        for( APLocationBlock block in _waitingBlocks )
        {
            CLLocationCoordinate2D coord = location.coordinate;
            APLOG(kDebugLocation, @"Calling(2) with: lat:%f long:%f", coord.latitude, coord.longitude);
            block(coord,nil);
        }
        [_waitingBlocks removeAllObjects];
    }
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    APLOG(kDebugLocation, @"Manager paused updates", 0);
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    APLOG(kDebugLocation, @"Manager resumed updates", 0);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self cancelTimeOut];
    APLOG(kDebugLocation, @"Manager failed with error: %@", error);
    [self stopService];
    NSArray *copyOfBlocks = [NSArray arrayWithArray:_waitingBlocks];
    APError *aperror = error.domain == kAPErrorDomain ? (APError *)error : [APError errorWithCode:kAPERROR_GPSSYSTEM];
    for( APLocationBlock block in copyOfBlocks )
    {
        CLLocationCoordinate2D coord = (CLLocationCoordinate2D){ 0, 0, };
        APLOG(kDebugLocation, @"Calling with error", 0);
        if( block(coord,aperror) == NO )
           [_waitingBlocks removeObject:block];
    }
    
    if( _waitingBlocks.count > 0 )
    {
        APLOG(kDebugLocation, @"Attempting with restart",0);
        [NSObject performBlock:^{
            [self startService];
        } afterDelay:3.0];
    }

}


@end

//
//  APLocation.m
//  ArgoPay
//
//  Created by victor on 9/30/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APLocation.h"
#import "APStrings.h"
#import "NSObject+VSBroadcasting.h"
#import "NSObject+BlocksKit.h"

#define kLocationFreshness 4.0

@implementation APLocation {
    CLLocation *          _lastLocation;
    bool                  _running;
    CLLocationManager *   _manager;
    NSMutableArray *      _waitingBlocks;
    CLAuthorizationStatus _currentStatus;
    BOOL                  _useSignificant;
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

-(id)init
{
    if( (self = [super init]) == nil )
        return nil;
    
    _waitingBlocks = [NSMutableArray new];
    _useSignificant = ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingFrequentGPS];
    
    [self registerForBroadcast:kNotifyUserSettingChanged block:^(APLocation *me, NSDictionary *settings)
    {
        for( NSString *key in settings )
        {
            if( [key isEqualToString:kSettingFrequentGPS] )
            {
                BOOL newSetting = ![settings[key] boolValue];
                if( newSetting != me->_useSignificant )
                {
                    APLOG(kDebugLocation, @"User set _useSignificant to: %d", newSetting);
                    me->_useSignificant = newSetting;
                    if( me->_running )
                    {
                        [me stopService];
                        me->_manager = nil;
                        [me startService];
                    }
                }
            }
        }
    }];
    return self;
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
    
    // If you don't do frequent updates, you may
    // never see another location for a while, even
    // if you restart/reinstantiate the manager
    if( !_useSignificant )
        _lastLocation = nil;
    
    APLOG(kDebugLocation, @"Starting updates (significant: %d)", _useSignificant);
    if( _useSignificant )
        [_manager startMonitoringSignificantLocationChanges];
    else
        [_manager startUpdatingLocation];
    _running = true;
}

-(void)stopService
{
    if( _running )
    {
        [self performSelectorOnMainThread:@selector(_stopService) withObject:nil waitUntilDone:YES];
    }
}

-(void)_stopService
{
    APLOG(kDebugLocation, @"Stopping manager", 0);
    _running = false;
    if( _useSignificant )
    {
        [_manager stopMonitoringSignificantLocationChanges];
        //
        // We might be shutting off to let the "allow location"
        // dialog to come to the front
        //
        if( _currentStatus == kCLAuthorizationStatusAuthorized )
        {
            // The significant updater does NOT pump a new
            // location the next time we restart UNLESS we
            // completely rebuild the location manager...
            //
            // EVEN THEN we may not see another another
            // location for a while
            //
            _manager = nil;
        }
    }
    else
    {
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
    if( _currentStatus != status )
    {
        // Restart the manager if we are moving in or out of
        // authorized state
        if( (_currentStatus == kCLAuthorizationStatusAuthorized) ||
           (status == kCLAuthorizationStatusAuthorized) )
        {
            [self stopService];
            _currentStatus = status;
            [self startService];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    NSTimeInterval howRecent = 0;
    if( _lastLocation )
        howRecent = [location.timestamp timeIntervalSinceDate:_lastLocation.timestamp];

    if ( !_lastLocation || (howRecent > kLocationFreshness) )
    {
        APLOG(kDebugLocation, @"Got: lat:%f long:%f recency: %f seconds",
              location.coordinate.latitude,
              location.coordinate.longitude,
              howRecent);
        
        _lastLocation = location;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:location.coordinate.latitude forKey:kSettingUserLastLat];
        [defaults setDouble:location.coordinate.longitude forKey:kSettingUserLastLong];
        
        NSArray *copyOfWaiting = [NSArray arrayWithArray:_waitingBlocks];
        for( APLocationBlock block in copyOfWaiting )
        {
            CLLocationCoordinate2D coord = location.coordinate;
            APLOG(kDebugLocation, @"Calling(2) with: lat:%f long:%f", coord.latitude, coord.longitude);
            block(coord,nil);
        }
        @synchronized(self) {
            [_waitingBlocks removeAllObjects];
        }
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
    APLOG(kDebugLocation, @"Manager failed with error: %@", error);
    [self stopService];
    NSArray *copyOfBlocks = [NSArray arrayWithArray:_waitingBlocks];
    NSMutableIndexSet * indexSet = [[NSMutableIndexSet alloc] init];
    APError *aperror = error.domain == kAPErrorDomain ? (APError *)error : [APError errorWithCode:kAPERROR_GPSSYSTEM];
    NSUInteger i = 0;
    for( APLocationBlock block in copyOfBlocks )
    {
        CLLocationCoordinate2D coord = (CLLocationCoordinate2D){ 0, 0, };
        APLOG(kDebugLocation, @"Calling with error", 0);
        if( block(coord,aperror) == NO )
           [indexSet addIndex:i];
        ++i;
    }
    
    @synchronized(self) {
        [_waitingBlocks removeObjectsAtIndexes:indexSet];
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

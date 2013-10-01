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

@implementation APLocation {
    CLLocationCoordinate2D _lastKnownSpot;
    bool _dataArrived;
    bool _running;
    CLLocationManager * _manager;
    NSDate *_lastRetrieved;
    NSMutableArray *_waitingBlocks;
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
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    APLOG(kDebugLocation, @"Initializing location delegate", 0);
    return self;
}

-(void)start
{
    _dataArrived = false;
    APLOG(kDebugLocation, @"Starting location delegate", 0);
    [_manager startMonitoringSignificantLocationChanges];
    _running = true;
}

-(void)stop
{
    if( _running )
    {
        APLOG(kDebugLocation, @"Stopping location delegate", 0);
        _running = false;
        [_manager stopMonitoringSignificantLocationChanges];
    }
}

-(void)currentLocation:(APNoLocationYetBlock)noLocation
           gotLocation:(APLocationBlock)gotBlock
{
    _lastKnownSpot = (CLLocationCoordinate2D){ 40, -70 };
    gotBlock(_lastKnownSpot);
    /*
    NSTimeInterval timeSinceLastLocation = abs([_lastRetrieved timeIntervalSinceNow] );
    
    APLOG(kDebugLocation, @"Requesting location: dataArrived: %d timeSinceLast: %G", _dataArrived, timeSinceLastLocation);

    if( _dataArrived && (timeSinceLastLocation <= kLocationGoesStaleAfterSeconds) )
    {
        APLOG(kDebugLocation, @"Calling(1) with: lat:%f long:%f", _lastKnownSpot.latitude, _lastKnownSpot.longitude);
        gotBlock(_lastKnownSpot);
    }
    else
    {
        if( _running )
        {
            noLocation();
            [_waitingBlocks addObject:[gotBlock copy]];
        }
        else
        {
            [self start];
        }
    }
     */
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];

    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    APDebug(kDebugLocation, @"Got location: lat:%f long:%f time:%@ now:%@ recency: %G",
            location.coordinate.latitude,
            location.coordinate.longitude,
            eventDate,
            [NSDate date],
            howRecent);
    
    if (abs(howRecent) < kLocationGoesStaleAfterSeconds )
    {
        _lastRetrieved = [NSDate date];
        _lastKnownSpot = location.coordinate;
        _dataArrived = true;
        for( APLocationBlock block in _waitingBlocks )
        {
            APLOG(kDebugLocation, @"Calling(2) with: lat:%f long:%f", _lastKnownSpot.latitude, _lastKnownSpot.longitude);
            block(_lastKnownSpot);
        }
        _waitingBlocks = [NSMutableArray new];
        [self stop];
    }
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    APLOG(kDebugLocation, @"Location manager paused updates", 0);
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    APLOG(kDebugLocation, @"Location manager resumed updates", 0);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    APLOG(kDebugLocation, @"Location manager failed with error: %@", error);
}


@end

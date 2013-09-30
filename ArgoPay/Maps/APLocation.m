//
//  APLocation.m
//  ArgoPay
//
//  Created by victor on 9/30/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APLocation.h"

#define kLocationGoesStaleAfterSeconds 30

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
    
    return self;
}

-(void)start
{
    _dataArrived = false;
    [_manager startMonitoringSignificantLocationChanges];
    _running = true;
}

-(void)stop
{
    if( _running )
    {
        _running = false;
        [_manager stopMonitoringSignificantLocationChanges];
    }
}

-(void)currentLocation:(APNoLocationYetBlock)noLocation
           gotLocation:(APLocationBlock)gotBlock
{
    if( _dataArrived && (abs([_lastRetrieved timeIntervalSinceNow]) <= kLocationGoesStaleAfterSeconds) )
    {
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
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];

    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    if (abs(howRecent) < kLocationGoesStaleAfterSeconds )
    {
        _lastRetrieved = [NSDate date];
        _lastKnownSpot = location.coordinate;
        _dataArrived = true;
        for( APLocationBlock block in _waitingBlocks )
            block(_lastKnownSpot);
        _waitingBlocks = [NSMutableArray new];
        [self stop];
    }
}
@end

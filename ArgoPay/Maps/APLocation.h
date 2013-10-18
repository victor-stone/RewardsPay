//
//  APLocation.h
//  ArgoPay
//
//  Created by victor on 9/30/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Return YES if you want to keep getting update (or try again after error)
// Return NO if you don't want to get get more updates
typedef void (^APLocationBlock)(CLLocationCoordinate2D loc);

@interface APLocation : NSObject <CLLocationManagerDelegate>

+(id)sharedInstance;

-(void)currentLocation:(APLocationBlock)gotBlock;
-(void)startService;
-(void)stopService;
@end

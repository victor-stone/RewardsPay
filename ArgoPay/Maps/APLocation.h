//
//  APLocation.h
//  ArgoPay
//
//  Created by victor on 9/30/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^APNoLocationYetBlock)();
typedef void (^APLocationBlock)(CLLocationCoordinate2D loc);

@interface APLocation : NSObject <CLLocationManagerDelegate>

+(id)sharedInstance;

-(void)currentLocation:(APNoLocationYetBlock)noLocation gotLocation:(APLocationBlock)gotBlock;
-(void)start;
-(void)stop;

@end

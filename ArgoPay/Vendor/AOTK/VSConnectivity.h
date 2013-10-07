//
//  VSConnectivity.h
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef VS_CONNECTIVITY_KEYS
extern NSString * kVSNotificationConnectionTypeChanged;
#endif

typedef enum _VSConnectType {
    kConnectionNone,
    kConnectionWifi,
    kConnectionCelluar
} VSConnectType;

/**
 *  Wrapper for iOS Reachability (refer to SCNetworkReachability API)
 *
 *  An instance of this object is sent as a payload for kVSNotificationConnectionTypeChanged event
 *
 * VSConnectType is defined as:
 *
 * ```
 typedef enum _VSConnectType {
 kConnectionNone,
 kConnectionWifi,
 kConnectionCelluar
 } VSConnectType;
 * ```
 */
@interface VSConnectivity : NSObject
-(id)initWithHost:(NSString *)host;
@property (nonatomic) VSConnectType connectionType;
@end

/**
 *  Simple object to encapsulate download progress
 *
 *  Used as payload in various notification broadcast events.
 *
 *  Refer to AFHTTPRequestOperation.setDownloadProgressBlock for values of these properties.
 */
@interface VSNetworkProgress : NSObject
@property (nonatomic) NSUInteger bytesRead;
@property (nonatomic) long long totalBytesRead;
@property (nonatomic) long long totalBytesExpected;
@end


//
//  APMerchantMap.h
//  ArgoPay
//
//  Created by victor on 10/7/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class APMerchant;

@interface APMerchantDetailMapEmbedding : UIViewController
@property (nonatomic,strong) APMerchant *merchant;
@property (nonatomic, strong) NSArray * merchants;

@end

@interface APMerchantMap : UIViewController
@property (nonatomic) CLLocationCoordinate2D homeLocation;
@property (nonatomic, strong) NSArray * merchants;
@end


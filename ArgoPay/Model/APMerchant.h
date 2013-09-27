//
//  APMerchant.h
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"

@class APMerchantPoints;

@interface APMerchant : APRemotableObject
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *Addr1;
@property (nonatomic,strong) NSString *Addr2;
@property (nonatomic,strong) NSString *City;
@property (nonatomic,strong) NSString *State;
@property (nonatomic,strong) NSString *Zip;
@property (nonatomic,strong) NSString *Tel;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSString *ImageURL;
@property (nonatomic,strong) NSString *Website;

@end

@interface APMerchantPoints : APRemotableObject
@property (nonatomic,strong) APMerchant * merchant;
@property (nonatomic,strong) NSNumber * points;
@property (nonatomic,strong) NSString * value;
@end
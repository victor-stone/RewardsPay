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

@property (nonatomic,strong) UIImage *logoImg;
@property (nonatomic,strong) UIImage *streetImage;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *zip;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *phone;

@property (nonatomic,strong) NSNumber *credits;

-(void)getMerchantPoints:(APRemoteAPIRequestBlock)block;
-(void)redeemPoints:(APMerchantPoints *)points block:(APRemoteAPIRequestBlock)block;

@end

@interface APMerchantPoints : APRemotableObject
@property (nonatomic,strong) APMerchant * merchant;
@property (nonatomic,strong) NSNumber * points;
@property (nonatomic,strong) NSString * value;
@end
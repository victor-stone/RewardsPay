//
//  APRemoteAPI.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APRemoteAPIRequestBlock)(id data, NSError *err);

@class APScanResult;
@class APReward;
@class APMerchant;
@class APMerchantPoints;

@interface APRemoteAPI : NSObject

+(id)sharedInstance;

-(void)getRewards:(APRemoteAPIRequestBlock)block;
-(void)getMerchantImage:(NSString *)name block:(APRemoteAPIRequestBlock)block;
-(void)requestTransaction:(APScanResult *)scanResult block:(APRemoteAPIRequestBlock)block;
-(void)redeemArgoPoints:(APReward *)reward block:(APRemoteAPIRequestBlock)block;
-(void)getMerchantPoints:(APMerchant *)merchant block:(APRemoteAPIRequestBlock)block;
-(void)redeemMerchantPoints:(APMerchantPoints *)points block:(APRemoteAPIRequestBlock)block;

@end

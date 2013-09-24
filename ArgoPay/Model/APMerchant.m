//
//  APMerchant.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"

@implementation APMerchant

-(void)getMerchantPoints:(APRemoteAPIRequestBlock)block
{
    APRemoteAPI * api = [APRemoteAPI sharedInstance];
    [api getMerchantPoints:self block:block];
}

-(void)redeemPoints:(APMerchantPoints *)points block:(APRemoteAPIRequestBlock)block
{
    APRemoteAPI * api = [APRemoteAPI sharedInstance];
    points.merchant = self;
    [api redeemMerchantPoints:points block:block];
}

@end

@implementation APMerchantPoints

@end
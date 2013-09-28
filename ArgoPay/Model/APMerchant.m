//
//  APMerchant.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"
#import "APRemoteStrings.h"

@implementation APMerchant

@end

@implementation APMerchantRewardListRequest

-(id)init
{
    return [super initWithCmd:kRemoteCmdMerchantLocationRewardList
                    subDomain:kRemoteSubDomainOffers];
}

-(Class)payloadClass
{
    return [APMerchantReward class];
}

-(NSString *)payloadName
{
    return kRemotePayloadRewardList;
}

@end

@implementation APMerchantReward

@end

@implementation APMerchantRewardRedeemd

-(id)init
{
    return [super initWithCmd:kRemoteCmdConsActivateReward
                    subDomain:kRemoteSubDomainOffers];
}
@end
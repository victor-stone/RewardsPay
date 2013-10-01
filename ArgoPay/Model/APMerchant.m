//
//  APMerchant.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"
#import "APRemoteStrings.h"
#import "APOffer.h"
#import "APArgoPointsReward.h"

@implementation APMerchant

@end

@implementation APRequestMerchantLocationSearch

-(id)init
{
    return [super initWithCmd:kRemoteCmdMerchantLocationSearch
                    subDomain:kRemoteSubDomainOffers];
}

-(Class)payloadClass
{
    return [APMerchant class];
}

-(NSString *)payloadName
{
    return kRemotePayloadLocations;
}
@end

@implementation APRequestMerchantLocationDetail

-(id)init
{
    return [super initWithCmd:kRemoteCmdMerchantLocationDetail
                    subDomain:kRemoteSubDomainOffers];
}

-(NSDictionary *)paths
{
    return @{ kRemotePayloadROOT: [APMerchantDetail class],
              kRemotePayloadOffers: [APOffer class],
              kRemotePayloadRewards: [APArgoPointsReward class]
              };
}
@end


@implementation APMerchantDetail
@end
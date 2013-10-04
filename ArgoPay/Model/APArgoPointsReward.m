//
//  APReward.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APArgoPointsReward.h"
#import "APStrings.h"
#import "APAccount.h"
#import "APRemoteStrings.h"

@implementation APRequestGetAvailableRewards

-(id)init
{
    self = [super initWithCmd:kRemoteCmdConsumerGetAvailableRewards
                    subDomain:kRemoteSubDomainOffers];
    if( !self ) return nil;
    
    _Limit = @(kRemoteArrayLimit);
    
    return self;
}

-(Class)payloadClass
{
    return [APArgoPointsReward class];
}

-(NSString *)payloadName
{
    return kRemotePayloadRewards;
}

@end

@implementation APArgoPointsReward {
    BOOL _isFetching;
}
-(BOOL)isFetching
{
    return _isFetching == YES;
}
-(void)setFetchingON
{
    _isFetching = YES;
}
-(void)setFetchingOFF
{
    _isFetching = NO;
}

@end

@implementation APRequestActivateReward
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsActivateReward
                    subDomain:kRemoteSubDomainOffers];
}
@end

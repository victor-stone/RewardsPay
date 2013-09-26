//
//  APReward.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APArgoPointsReward.h"
#import "APStrings.h"
#import "APRemoteAPI.h"
#import "APAccount.h"

@implementation APArgoPointsReward

-(id)initWithDictionary:(NSDictionary *)values
{
    self = [super initWithDictionary:values];
    if( !self )
        return nil;
    
    [self calcStatus];
    return self;
}

-(void)setStatus:(APRewardStatus)status
{
    _status = status;
    [self broadcast:kNotifyRewardStatusChange payload:self];
}

-(void)calcStatus
{
    if( (_status != kRewardStatusSeekingRedemption) && (_status != kRewardStatusReadyToUse) )
    {
        APAccount *account = [APAccount sharedInstance];
        NSInteger argoPoints = [account.argoPoints integerValue];
        if( argoPoints > [_points integerValue] )
            _status = kRewardStatusRedeemable;
    }
}

-(void)redeem:(APRemoteAPIRequestBlock)block
{
    self.status = kRewardStatusSeekingRedemption;
    APRemoteAPI *api = [APRemoteAPI sharedInstance];
    [api redeemArgoPoints:self block:^(APArgoPointsReward *result,NSError *err) {
        if( !err )
            [result calcStatus];
        block(result,err);
    }];
}
@end

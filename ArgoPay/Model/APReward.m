//
//  APReward.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APReward.h"
#import "APStrings.h"
#import "APRemoteAPI.h"

@implementation APReward

-(void)setStatus:(APRewardStatus)status
{
    _status = status;
    [self broadcast:kNotifyRewardStatusChange payload:self];
}

-(void)redeem:(APRemoteAPIRequestBlock)block
{
    self.status = kRewardStatusSeekingRedemption;
    APRemoteAPI *api = [APRemoteAPI sharedInstance];
    [api redeemArgoPoints:self block:^(NSArray *rewards,NSError *err) {
        APReward * result = nil;
        if( !err )
        {
            for( result in rewards )
            {
                if( [result.key isEqual:self.key] )
                {
                    break;
                }
            }
        }
        block(result,err);
    }];
}
@end

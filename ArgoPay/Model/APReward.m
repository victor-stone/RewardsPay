//
//  APReward.m
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APReward.h"
#import "APStrings.h"

@implementation APReward

+(id)rewardsForAccount
{
    return nil;
}

-(void)setStatus:(APRewardStatus)status
{
    _status = status;
    [self broadcast:kNotifyRewardStatusChange payload:self];
}

-(void)redeem
{
    
}
@end

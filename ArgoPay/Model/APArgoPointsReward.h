//
//  APReward.h
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"

@class APMerchant;

typedef enum _APRewardStatus {
    kRewardStatusCantAfford,
    kRewardStatusRedeemable,
    kRewardStatusReadyToUse,
    kRewardStatusSeekingRedemption
} APRewardStatus;

@interface APArgoPointsReward : APRemotableObject

@property (nonatomic,strong) APMerchant    * merchant;
@property (nonatomic,strong) NSNumber      * points;
@property (nonatomic,strong) NSNumber      * credit;
@property (nonatomic)        APRewardStatus  status;

-(void)redeem:(APRemoteAPIRequestBlock)block;

@end


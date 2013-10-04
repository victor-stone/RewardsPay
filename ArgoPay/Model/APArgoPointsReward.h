//
//  APReward.h
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"

/*
 /ConsumerGetAvailableRewards (Limit is Quantity of records to return)
                                (SortBy is (N)one, W-Newest First, (R)eady to use, (A)vailable to Select, (E)xpiring Soon)
                                (Selected means that the offer has already been selected by the consumer)
                                (Redeemable means only offers that the consumer can now redeem instead of all rewards (Y/N))
 > AToken, Lat, Long, Distance, Redeemable, SortBy
 < Status, Message, Rewards (see below) (see APMerchant.h)
*/
@interface APRequestGetAvailableRewards : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSNumber *Distance;
@property (nonatomic,strong) NSString *SortBy;
@property (nonatomic,strong) NSNumber *Limit;
@end

/*
 {RewardID, DateFrom, Selected, Selectable, DateTo, AmountReward, AmountMinimum, MultipleUse, PointsRequired
 
 */
@interface APArgoPointsReward : APMerchant
@property (nonatomic,strong) NSString *RewardID;
@property (nonatomic,strong) NSString *DateFrom;
@property (nonatomic,strong) NSString *Selected;
@property (nonatomic,strong) NSString *Selectable;
@property (nonatomic,strong) NSString *DateTo;
@property (nonatomic,strong) NSNumber *AmountReward;
@property (nonatomic,strong) NSNumber *AmountMinimum;
@property (nonatomic,strong) NSString *MultipleUse;
@property (nonatomic,strong) NSNumber *PointsRequired;
-(BOOL)isFetching; // UI Runtime stuff (don't make a property which will confuse the JSON verifier)
-(void)setFetchingON;
-(void)setFetchingOFF;
@end

@interface APRequestActivateReward : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *RewardID;
@end

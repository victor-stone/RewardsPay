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
 > AToken, Lat, Long, Distance, Limit, SortBy
 < Status, Message, Rewards 
      {RewardID, DateFrom, Selected, DateTo, Count, AmountReward, AmountMinimum, MultipleUse,
      Nam, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, ImageURL, Website}
 
 Status, Message, Rewards {RewardID, DateFrom, Selected, DateTo, 
 AmountReward, AmountMinimum, MultipleUse, PointsRequired
 Name, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, ImageURL, Website}
 

 */


@interface APRequestRewards : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSNumber *Distance;
@property (nonatomic,strong) NSString *SortBy;
@property (nonatomic,strong) NSNumber *Limit;
@end

@interface APArgoPointsReward : APMerchant
@property (nonatomic,strong) NSString *RewardID;
@property (nonatomic,strong) NSNumber *Selected;
@property (nonatomic,strong) NSString *DateFrom;
@property (nonatomic,strong) NSString *DateTo;
@property (nonatomic,strong) NSNumber *PointsRequired;
@property (nonatomic,strong) NSNumber *AmountReward;
@property (nonatomic,strong) NSNumber *AmountMinimum;
@property (nonatomic,strong) NSString *MultipleUse;
@property (nonatomic,strong) NSString *Description;
@end

/*
 /ConsActivateReward
 >AToken, RewardID
 <Status, Message, UserMessage
 */
@interface APActivateReward : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *RewardID;
@end

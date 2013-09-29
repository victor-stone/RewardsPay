//
//  APMerchant.h
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteObject.h"

@interface APMerchant : APRemoteObject
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *Addr1;
@property (nonatomic,strong) NSString *Addr2;
@property (nonatomic,strong) NSString *City;
@property (nonatomic,strong) NSString *State;
@property (nonatomic,strong) NSString *Zip;
@property (nonatomic,strong) NSString *Tel;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSString *ImageURL;
@property (nonatomic,strong) NSString *Website;

@end

@interface APMerchantRewardListRequest : APRemoteCommand
@property (nonatomic,strong) NSString *MToken;
@property (nonatomic,strong) NSString *MLocID;
@end

@interface APMerchantReward : APRemoteObject

@property (nonatomic,strong) NSNumber * RewardID;
@property (nonatomic,strong) NSString *DateFrom;
@property (nonatomic,strong) NSString *DateTo;
@property (nonatomic,strong) NSNumber * AmountReward;
@property (nonatomic,strong) NSNumber * AmountMinimum;
@property (nonatomic,strong) NSNumber * MultipleUse;
@property (nonatomic,strong) NSNumber * PointsRequired;
@end

@interface APMerchantRewardRedeemd : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSNumber *RewardID;
@end

//
//  APOffer.h
//  ArgoPay
//
//  Created by victor on 9/24/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"

@interface APRequestOffers : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSNumber *Distance;
@property (nonatomic,strong) NSString *SortBy;
@property (nonatomic,strong) NSNumber *Limit;
@end

@interface APOffer : APMerchant

@property (nonatomic,strong) NSString *OfferID;
@property (nonatomic,strong) NSString *Type;
@property (nonatomic,strong) NSString *Selected;
@property (nonatomic,strong) NSString *DateFrom;
@property (nonatomic,strong) NSString *DateTo;
@property (nonatomic,strong) NSNumber *DaysToUse;
@property (nonatomic,strong) NSNumber *Count;
@property (nonatomic,strong) NSNumber *AmountDiscount;
@property (nonatomic,strong) NSNumber *AmountMinimum;
@property (nonatomic,strong) NSNumber *PointBonus;
@property (nonatomic,strong) NSNumber *PointMultiplier;
@property (nonatomic,strong) NSNumber *ArgoBonus;
@property (nonatomic,strong) NSNumber *ArgoMultiplier;
@property (nonatomic,strong) NSString *Description;

@end


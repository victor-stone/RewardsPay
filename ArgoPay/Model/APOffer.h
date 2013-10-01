//
//  APOffer.h
//  ArgoPay
//
//  Created by victor on 9/24/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"

/*
 /ConsumerGetAvailableOffers   (Limit is Quantity of Records to return)
                                 (SortBy is (N)one, W-Newest First, (R)eady to use, (A)vailable to Select, (E)xpiring Soon)
                                 (Selected means that the offer has already been selected by the consumer)
 > AToken, Lat, Long, Distance, Limit, SortBy
 < Status, Message, Offers: (see below) (see APMerchant.h)
  */
@interface APRequestGetAvailableOffers : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSNumber *Distance;
@property (nonatomic,strong) NSString *SortBy;
@property (nonatomic,strong) NSNumber *Limit;
@end

/*
 {OfferID, Type, Selected, DateFrom, DateTo, DaysToUse, Count, AmountDiscount, 
 AmountMinimum, PointBonus, PointMultiplier, ArgoBonus, ArgoMultiplier,
 
 */
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
@end

/*
 /ConsActivateOffer
 >AToken, OfferID
 <Status, Message, UserMessage
 */
@interface APRequestActivateOffer : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *OfferID;
@end
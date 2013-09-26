//
//  APOffer.h
//  ArgoPay
//
//  Created by victor on 9/24/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"

@class APMerchant;

/*
 /ConsumerGetAvailableOffers   (Limit is Quantity of Records to return)
                               (SortBy is (N)one, W-Newest First, (R)eady to use, (A)vailable to Select, (E)xpiring Soon)
                               (Selected means that the offer has already been selected by the consumer)
 > AToken, Lat, Long, Distance, Limit, SortBy
 <    Status, 
      Message,
      Offers
        { OfferID, Type, Selected, DateFrom, DateTo, 
           DaysToUse, Count, AmountDiscount, AmountMinimum,
           PointBonus, PointMultiplier, ArgoBonus, ArgoMultiplier,
           Nam, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, 
           ImageURL, Website
        }
 */

@interface APRequestOffers : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSNumber *Distance;
@property (nonatomic,strong) NSString *SortBy;
@property (nonatomic,strong) NSNumber *Limit;
@end

typedef enum _APOfferSort {
    kOfferSortNone,
    kOfferSortNewest,
    kOfferSortReadyToUse,
    kOfferSortAvailableToSelect,
    kOfferSortExpiringSoon,
    kOfferSortRecommended
    
} APOfferSort;

@interface APOffer : APRemotableObject

@property (nonatomic,strong) APMerchant *merchant;
@property (nonatomic,strong) NSNumber *expires;
@property (nonatomic,strong) NSNumber *created;
@property (nonatomic,strong) NSString *description;
@property (nonatomic,strong) NSNumber *selected;
@property (nonatomic,strong) NSNumber *recommendationWeight;

-(NSUInteger)daysToExpire;

@end

@interface NSArray (OfferSorter)
-(NSArray *)arrayByOfferSort:(APOfferSort)sort;
@end


//
//  APMerchant.h
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteObject.h"


/*
 MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, 
 Lat, Long, Description, , ImageURL, Website}
 */
/*
{MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel,
 Lat, Long, Description, ImageURL, Website}
 */
/*
 MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, 
 Lat, Long, Description, ImageURL, Website}
 */
@interface APMerchant : APRemoteObject
@property (nonatomic,strong) NSNumber *MLocID;
@property (nonatomic,strong) NSString *Category;
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
@property (nonatomic,strong) NSString *Description;
@property (nonatomic,strong) NSString *LongDescription; // volatile
@end

/*
 
 /MerchantLocationSearch (Searches for locations of merchants locations nearby)
                         (Used by consumers to search for merchants that take ArgoPay)
                         (Limit specificies how many merchant locations to return)
                         (SortBy specifies the sort order (D)istance, (C)ategory)
                         (CategoryID specific a specific Category ID)
 >Lat, Long, Distance, Limit, SortBy, CategoryID
 <Status, Message, Locations:{MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, 
 Lat, Long, Description, ImageURL, Website}
 */

@interface APRequestMerchantLocationSearch : APRemoteRequest // ---->Payload: APMerchant
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@property (nonatomic,strong) NSNumber *Distance;
@property (nonatomic,strong) NSNumber *Limit;
@property (nonatomic,strong) NSString *SortBy; // 'D'istance, 'C'ategory
@property (nonatomic,strong) NSNumber *CategoryID;
@end

/*
 /MerchantLocationDetail (Displays the detail for a Merchant)
                         (Shows all rewards and offers available for a merchant location
                         (AToken: Optional if AToken is valid, then we also return consumer based data also.)
                         (MLocID: Required.   Specifies a MLocID from previous call)
 >AToken, MLocID

 <MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, ImageURL, Website, 
 
 ConsumerPoints,
 
 Offers: {OfferID, Type, Selected, DateFrom, DateTo, DaysToUse, Count, AmountDiscount, AmountMinimum, 
 PointBonus, PointMultiplier, ArgoBonus, ArgoMultiplier,
 Description, LongDescription},
 
 Rewards: {RewardID, DateFrom, Selected, Selectable, DateTo, AmountReward, 
 AmountMinimum, MultipleUse, PointsRequired,
 Description, LongDescription}
 
 */

@interface APRequestMerchantLocationDetail  : APRemoteRequest
@property (nonatomic,strong) NSString *AToken; // can be nil
@property (nonatomic,strong) NSNumber *MLocID;
@end

@interface APMerchantDetail  : APMerchant
@property (nonatomic,strong) NSNumber *ConsumerPoints;
@property (nonatomic,strong) NSArray *Offers;
@property (nonatomic,strong) NSArray *Rewards;
@end


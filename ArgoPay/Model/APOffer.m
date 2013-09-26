//
//  APOffer.m
//  ArgoPay
//
//  Created by victor on 9/24/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APOffer.h"
#import "APRemoteStrings.h"

@implementation APRequestOffers

-(id)init
{
    self = [super initWithCmd:kRemoteCmdConsumerGetAvailableOffers subDomain:kRemoteSubDomainOffers];
    if( !self ) return nil;
    
    _Limit = @(kRemoteArrayLimit);
    
    return self;
}

-(Class)payloadClass
{
    return [APOffer class];
}
@end

@implementation APOffer

-(NSUInteger)daysToExpire
{
    NSDate *expiresDate = [NSDate dateWithTimeIntervalSince1970:[self.expires doubleValue]];
    NSTimeInterval lastDiff = [expiresDate timeIntervalSinceNow];
    NSTimeInterval todaysDiff = [[NSDate date] timeIntervalSinceNow];
    NSTimeInterval dateDiff = lastDiff - todaysDiff;
#define ONE_DAY (60UL * 60UL * 24UL)
    return (NSUInteger)(dateDiff / ONE_DAY);
}
@end


@implementation  NSArray (OfferSorter)


-(NSArray *)arrayByOfferSort:(APOfferSort)sort
{
    NSComparator sorter = nil;
    switch (sort) {
        case kOfferSortAvailableToSelect:
        {
            sorter = ^NSComparisonResult(APOffer * obj1, APOffer * obj2) {
                return ![obj1.selected boolValue] ? NSOrderedAscending : NSOrderedDescending;
            };
            break;
        }
        case kOfferSortExpiringSoon:
        {
            sorter = ^NSComparisonResult(APOffer * obj1, APOffer * obj2) {
                NSUInteger days1 = obj1.daysToExpire;
                NSUInteger days2 = obj2.daysToExpire;
                return days1 > days2 ? NSOrderedDescending : NSOrderedAscending;
            };
            break;
        }
        case kOfferSortNewest:
        {
            sorter = ^NSComparisonResult(APOffer * obj1, APOffer * obj2) {
                NSTimeInterval date1 = [obj1.created doubleValue];
                NSTimeInterval date2 = [obj2.created doubleValue];
                return date1 > date2 ? NSOrderedDescending : NSOrderedAscending;
            };
            break;
        }
        case kOfferSortReadyToUse:
        {
            sorter = ^NSComparisonResult(APOffer * obj1, APOffer * obj2) {
                return [obj1.selected boolValue] ? NSOrderedAscending : NSOrderedDescending;
            };
            break;
        }
        case kOfferSortRecommended:
        {
            sorter = ^NSComparisonResult(APOffer * obj1, APOffer * obj2) {
                CGFloat r1 = [obj1.recommendationWeight floatValue];
                CGFloat r2 = [obj2.recommendationWeight floatValue];
                return r1 > r2 ? NSOrderedDescending : NSOrderedAscending;
            };
            break;
        }
        default:
            NSAssert(0, @"Invalid offer sort request");
            return nil;
    }
    
    return [self sortedArrayUsingComparator:sorter];
}
@end
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
    self = [super initWithCmd:kRemoteCmdConsumerGetAvailableOffers
                    subDomain:kRemoteSubDomainOffers];
    if( !self ) return nil;
    
    _Limit = @(kRemoteArrayLimit);
    
    return self;
}

-(Class)payloadClass
{
    return [APOffer class];
}

-(NSString *)payloadName
{
    return kRemotePayloadOffers;
}

@end

@implementation APOffer

@end



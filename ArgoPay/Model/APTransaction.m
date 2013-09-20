//
//  APTransactionResult.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APTransaction.h"
#import "APStrings.h"
#import "APRemoteAPI.h"

@implementation APTransaction
@end

@implementation APTransactionRequest

APLOGRELEASE

-(id)initWithScanResult:(APScanResult *)scanResult
{
    if( (self = [super init]) == nil )
        return nil;
    
    APRemoteAPI * api = [APRemoteAPI sharedInstance];
    [api requestTransaction:scanResult block:^(id data) {
        _transaction = data;
        [self broadcast:kNotifyTransactionResult payload:self];
    }];
    _state = kTransactionStateUnknown;
    return self;
}


-(void)accept
{
    _state = kTransactionStateAccepted;
    [self broadcast:kNotifyTransactionComplete payload:self];
}

-(void)cancel
{
    _state = kTransactionStateCancelled;
    [self broadcast:kNotifyTransactionComplete payload:self];
}

@end
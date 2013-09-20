//
//  APTransactionResult.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APTransaction.h"
#import "APStrings.h"

@implementation APTransaction
@end

@implementation APTransactionRequest

APLOGRELEASE

-(id)initWithScanResult:(APScanResult *)scanResult
{
    if( (self = [super init]) == nil )
        return nil;
    
    [NSObject performBlock:^{
        APTransaction * result = [[APTransaction alloc] init];
        result.merchantItem = @"Happy Oranges by the Side of the Freeway";
        result.merchantName = @"Happy Time Fruit Co.";
        result.grandTotal = @(29.99);
        _transaction = result;
        [self broadcast:kNotifyTransactionResult payload:self];
    } afterDelay:2.5];
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
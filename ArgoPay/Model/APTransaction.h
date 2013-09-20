//
//  APTransactionResult.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"
@class APScanResult;
@class APMerchant;

@interface APTransaction : APRemotableObject
@property (nonatomic,strong) APMerchant *merchant;
@property (nonatomic,strong) NSString * merchantItem;
@property (nonatomic,strong) NSNumber * grandTotal;
@end

typedef enum _APTranasctionRequestState {
    kTransactionStateUnknown = 0,
    kTransactionStateAccepted,
    kTransactionStateCancelled
} APTransactionRequestState;

@interface APTransactionRequest : NSObject
@property (nonatomic,strong) APTransaction * transaction;
@property (nonatomic,readonly) APTransactionRequestState state;

-(id)initWithScanResult:(APScanResult *)scanResult;
-(void)accept;
-(void)cancel;
@end
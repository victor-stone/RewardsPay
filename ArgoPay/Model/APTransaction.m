//
//  APTransactionResult.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APTransaction.h"
#import "APStrings.h"
#import "APRemoteStrings.h"

@implementation APTransactionStartRequest
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerTransactionStart
                    subDomain:kRemoteSubDomainTransaction];
}

-(Class)payloadClass
{
    return [APTransactionIDResponse class];
}
@end

@implementation APTransactionIDResponse
@end

@implementation APTransactionStatusRequest
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerTransactionStatus
                    subDomain:kRemoteSubDomainTransaction];
}

-(Class)payloadClass
{
    return [APTransactionStatusResponse class];
}
@end


@implementation APTransactionStatusResponse
@end

/*
 
 /ConsumerTransactionApprove
 >AToken, TransID, Approve (Binary [Y/N])
 <Status, Message, UserMessage
 */
@implementation APTransactionApprovalRequest
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerTransactionApprove
                    subDomain:kRemoteSubDomainTransaction];
}
@end


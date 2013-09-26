//
//  APError.m
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#define APERROR_DECLS

#import "APError.h"

NSString * kAPErrorDomain = @"com.ArgoPay.ArgoPayMobile.ErrorDomain";

@implementation APError

-(id)initWithMsg:(NSString *)msg
{
    return [super initWithDomain:kAPErrorDomain code:0x100 userInfo:@{NSLocalizedDescriptionKey:msg}];
}
@end

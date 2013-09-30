//
//  APError.m
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#define APERROR_DECLS

#import "APError.h"

NSString *const kAPMobileErrorDomain = @"com.ArgoPay.ArgoPayMobile.ErrorDomain";
NSString *const kAPErrorDomain       = @"com.ArgoPay.ArgoPay.ErrorDomain";
NSString *const kAPClientErrorKey = @"kAPClientErrorKey";
NSString *const kAPServerErrorKey = @"kAPServerErrorKey";

@implementation APError

+(id)errorWithCode:(NSUInteger)code;
{
    NSString *msg = nil;
    switch (code) {
        case kAPERROR_MISSINGLOGINFIELDS:
            msg = NSLocalizedString(@"Both login name and password are required to login", @"Account login error");
            break;
            
        case kAPERROR_NONETCONNECTION:
            msg = NSLocalizedString(@"This app requires a network connection.", @"Network error");
            break;
            
        default:
            msg = NSLocalizedString(@"Sorry, but something didn't quite right", @"Generic error");
            break;
    }
    
    return [[APError alloc] initWithMsg:msg code:code];
}

-(id)initWithMsg:(NSString *)msg code:(NSUInteger)code
{
    return [super initWithDomain:kAPMobileErrorDomain
                            code:code
                        userInfo:@{ NSLocalizedDescriptionKey:msg,
               kAPClientErrorKey: @(YES)} ];
    
}

-(id)initWithMsg:(NSString *)msg
{
    return [super initWithDomain:kAPMobileErrorDomain
                            code:KAPERROR_GENERIC
                        userInfo:@{ NSLocalizedDescriptionKey:msg,
                                    kAPClientErrorKey: @(YES)} ];
}

-(id)initWithMsg:(NSString *)msg serverStatus:(NSUInteger)serverStatus
{
    return [super initWithDomain:kAPErrorDomain
                            code:serverStatus
                        userInfo:@{ NSLocalizedDescriptionKey:msg,
               kAPServerErrorKey: @(YES)} ];    
}

@end

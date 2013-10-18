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

NSString *const kAPYouDontHaveToGoHomeButYouCantStayHereKey = @"kAPYouDontHaveToGoHomeButYouCantStayHereKey";

@implementation APError


+(id)errorWithCode:(NSUInteger)code
{
    return [APError errorWithCode:code userInfo:nil];
}

+(id)errorWithCode:(NSUInteger)code userInfo:(NSDictionary *)userInfo
{
    NSString *msg = nil;
    switch (code) {
        case kAPERROR_MISSINGLOGINFIELDS:
            msg = NSLocalizedString(@"Both login name and password are required to login", @"Account login error");
            break;
            
        case kAPERROR_NONETCONNECTION:
            msg = NSLocalizedString(@"ArgoPay requires a network connection.", @"Network error");
            break;
            
        case kAPERROR_GPSSYSTEM:
        case kAPERROR_NOGPS:
            msg = NSLocalizedString(@"ArgoPay requires that you allow us access to your current location. Go the Settings app and change the settings at\nPrivacy->Location", @"GPS error");
            break;
            
        case kAPERROR_GPSTIMEOUT:
            msg = NSLocalizedString(@"Location data taking too long.", @"GPS error");
            break;
            
        default:
            msg = NSLocalizedString(@"Sorry, but something didn't quite right", @"Generic error");
            break;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    dict[NSLocalizedDescriptionKey] = msg;
    
    return [[APError alloc] initWithCode:code userInfo:dict];
}

-(id)initWithCode:(NSUInteger)code userInfo:(NSDictionary *)userInfo
{
    return [super initWithDomain:kAPMobileErrorDomain
                            code:code
                        userInfo:userInfo
            ];
    
}

+(id)errorWithMsg:(NSString *)msg serverStatus:(NSUInteger)serverStatus;
{
    NSString *kcontinue = NSLocalizedString(@"Continue", @"Error button");
    return [[APError alloc] initWithCode:kAPERROR_ARGOPAYSERVER userInfo:@
    {
        NSLocalizedDescriptionKey: msg,
        kAPYouDontHaveToGoHomeButYouCantStayHereKey: kcontinue
    }];
}


@end

//
//  APError.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef APERROR_DECLS

extern NSString *const kAPErrorDomain;

extern NSString *const kAPYouDontHaveToGoHomeButYouCantStayHereKey;

#endif

#define kAPERROR_BASE               1
#define KAPERROR_GENERIC            kAPERROR_BASE
#define kAPERROR_MISSINGLOGINFIELDS (kAPERROR_BASE + 1)
#define kAPERROR_NONETCONNECTION    (kAPERROR_BASE + 2)
#define kAPERROR_NOGPS              (kAPERROR_BASE + 3)
#define kAPERROR_GPSTIMEOUT         (kAPERROR_BASE + 4)
#define kAPERROR_GPSSYSTEM          (kAPERROR_BASE + 5)
#define kAPERROR_ARGOPAYSERVER      (kAPERROR_BASE + 6)
#define kAPERROR_TRANSACTIONTIMEOUT (kAPERROR_BASE + 7)

@interface APError : NSError
+(id)errorWithCode:(NSUInteger)code;
+(id)errorWithCode:(NSUInteger)code userInfo:(NSDictionary *)userInfo;
+(id)errorWithMsg:(NSString *)msg serverStatus:(NSUInteger)serverStatus;
@end

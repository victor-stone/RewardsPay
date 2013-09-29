//
//  APError.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef APERROR_DECLS
extern NSString *const kAPMobileErrorDomain;
extern NSString *const kAPErrorDomain;
extern NSString *const kAPClientErrorKey;
extern NSString *const kAPServerErrorKey;
#endif

#define kAPERROR_BASE               0x100
#define KAPERROR_GENERIC            kAPERROR_BASE
#define kAPERROR_MISSINGLOGINFIELDS (kAPERROR_BASE + 1)

@interface APError : NSError
+(id)errorWithCode:(NSUInteger)code;
-(id)initWithMsg:(NSString *)msg;
-(id)initWithMsg:(NSString *)msg serverStatus:(NSUInteger)serverStatus;
@end

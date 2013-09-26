//
//  APError.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef APERROR_DECLS
extern NSString * kAPErrorDomain;
#endif

@interface APError : NSError
-(id)initWithMsg:(NSString *)msg;
@end

//
//  NSString+APNetwork.m
//  ArgoPay
//
//  Created by victor on 9/29/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "NSString+APNetwork.h"
#import "APRemoteStrings.h"

@implementation NSString (APNetwork)

-(BOOL)isRemoteYES
{
    return [self isEqualToString:kRemoteValueYES];
}
@end

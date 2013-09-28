//
//  NSObject+KeyPaths.m
//  ArgoPay
//
//  Created by victor on 9/27/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "NSObject+KeyPaths.h"
#import <objc/runtime.h>

@implementation NSObject (KeyPaths)

-(NSArray*) keyPaths
{
    NSMutableArray *result = [NSMutableArray new];
    
    unsigned int count;
    objc_property_t *props = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; ++i)
    {
        const char *propName = property_getName(props[i]);
        [result addObject:[NSString stringWithUTF8String:propName]];
    }
    
    free(props);
    return result;
}


@end

//
//  APRemotableObject.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"


static unsigned int __testingCounter = 0;

@implementation APRemotableObject {
    NSMutableDictionary * _propDict;
}

-(id)initWithDictionary:(NSDictionary *)values
{
    if( (self = [super init]) == nil )
        return nil;
    
    _propDict = [NSMutableDictionary new];
    
    if( !_key )
        _key = @(++__testingCounter);
    
    [self setValuesForKeysWithDictionary:values];
    
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    _propDict[key] = value;
}

-(id)valueForUndefinedKey:(NSString *)key
{
    return _propDict[key];
}

@end
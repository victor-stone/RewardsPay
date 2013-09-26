//
//  APRemotableObject.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"
#import "APStrings.h"
#import <objc/runtime.h>

@implementation APRemotableObject {
    NSMutableDictionary * _propDict;
}

APLOGRELEASE

-(id)initWithDictionary:(NSDictionary *)values
{
    if( (self = [super init]) == nil )
        return nil;
    
    _propDict = [NSMutableDictionary new];
    
    [self setValuesForKeysWithDictionary:values];
    
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    _propDict[key] = value;
}

@end

@implementation APRemoteCommand {
    NSMutableDictionary *_shippingProperties;
}

-(id)initWithCmd:(NSString *)cmd subDomain:(NSString *)subDomain
{
    self = [super init];
    if( !self ) return nil;
    
    _shippingProperties = [NSMutableDictionary new];
    _command = cmd;
    _subDomain = subDomain;
    NSMutableDictionary *props = _shippingProperties;
    [self addObserverForKeyPaths:[self keyPaths]
                         options:NSKeyValueObservingOptionNew
                            task:^(id obj, NSString *keyPath, NSDictionary *change) {
                                props[keyPath] = change[NSKeyValueChangeNewKey];
                            }];
    return self;
}

-(void)dealloc
{
    [self removeAllBlockObservers];
}

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

-(NSDictionary *)remotableProperties
{
    return _shippingProperties;
}

-(Class)payloadClass
{
    return [APRemoteRepsonse class];
}

-(void)willSend {}
-(void)didGetResponse:(id)responseObject {}
-(void)didGetError:(NSError *)error {}

@end

@implementation APRemoteRepsonse
@end


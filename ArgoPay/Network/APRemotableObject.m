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

-(id)valueForUndefinedKey:(NSString *)key
{
    return _propDict[key];
}

@end

@implementation APRemoteCommand {
    NSMutableDictionary *_shippingProperties;
    NSString *_watcherKey;
}

-(id)initWithCmd:(NSString *)cmd subDomain:(NSString *)subDomain
{
    self = [super init];
    if( !self ) return nil;
    
    _shippingProperties = [NSMutableDictionary new];
    _command = cmd;
    _subDomain = subDomain;
    NSMutableDictionary *props = _shippingProperties;
    _watcherKey = [self addObserverForKeyPaths:[self keyPaths]
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

-(void)didChangeValueForKey:(NSString *)key
{
    [super didChangeValueForKey:key];
    _shippingProperties[key] = [self valueForKey:key];
}

-(NSDictionary *)remotableProperties
{
    return _shippingProperties;
}

-(Class)payloadClass
{
    NSAssert(0, @"Derived classes must set the 'payloadClass' property");
    return nil;
}

-(void)willSend {}
-(void)didGetResponse:(id)responseObject {}
-(void)didGetError:(NSError *)error {}

@end
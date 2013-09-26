//
//  APRemotableObject.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"
#import "APStrings.h"


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
}

-(id)initWithCmd:(NSString *)cmd subDomain:(NSString *)subDomain
{
    self = [super init];
    if( !self ) return nil;
    
    _shippingProperties = [NSMutableDictionary new];
    _command = cmd;
    _subDomain = subDomain;
    return self;
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
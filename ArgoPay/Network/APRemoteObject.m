//
//  APRemotableObject.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteObject.h"
#import "APStrings.h"
#import "APRemoteStrings.h"

@implementation APRemoteObject {
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

-(NSString *)formatDateField:(NSString *)nameOfDateField
{
    return [self formatDateField:nameOfDateField style:NSDateFormatterMediumStyle];
}

-(NSString *)formatDateField:(NSString *)nameOfDateField style:(NSDateFormatterStyle)style
{
    NSString *value = [self valueForKey:nameOfDateField];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [fmt dateFromString:value];
    if( !date )
    {
        [fmt setDateFormat:@"yyyy-MM-dd"];
        date = [fmt dateFromString:value];
    }
    return [NSDateFormatter localizedStringFromDate:date dateStyle:style timeStyle:NSDateFormatterNoStyle];
}
@end

@implementation APRemoteRequest {
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
    NSArray *propertyNames = [self keyPaths];
    if( propertyNames.count > 0 )
    {
        // there's some quirky bug in Blocks stuff, don't have time
        // to chase it down now. Work around: check for case where
        // there's only one property on the object to watch and
        // special case:
        if( propertyNames.count == 1 )
        {
            NSString *key = propertyNames[0];
            [self addObserverForKeyPath:key options:NSKeyValueObservingOptionNew
                                   task:^(id obj, NSDictionary *change) {
                                       props[key] = change[NSKeyValueChangeNewKey];
                                   }];
        }
        else
        {
            [self addObserverForKeyPaths:[self keyPaths]
                                 options:NSKeyValueObservingOptionNew
                                    task:^(id obj, NSString *keyPath, NSDictionary *change) {
                                        props[keyPath] = change[NSKeyValueChangeNewKey];
                                    }];
            
        }
    }
    return self;
}

-(void)dealloc
{
    [self removeAllBlockObservers];
}

-(NSDictionary *)remotableProperties
{
    return _shippingProperties;
}

-(Class)payloadClass
{
    return [APRemoteRepsonse class];
}

-(NSString *)payloadName
{
    return kRemotePayloadROOT;
}

-(NSDictionary *)paths
{
    return @{ [self payloadName]: [self payloadClass] };
}

@end

@implementation APRemoteRepsonse
@end


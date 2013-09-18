//
//  NSObject+VSBroadcasting.m
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import "NSObject+VSBroadcasting.h"


static void * kVSRegistrationIdentifiers = &kVSRegistrationIdentifiers;

/**
 @internal
 */
@interface VSNotificationTokens : NSObject
@property (nonatomic,assign) NSObject * target;
@property (nonatomic,strong) NSMutableArray * tokens;
+ (id) attachTo: (id) target;
@end

/**
 @internal
 */
@interface VSNotificationBus : NSObject
+(id)sharedInstance;
@property (nonatomic,strong) NSMutableDictionary *autoDeregister;
-(void)notify:(NSString *)message obj:(id)obj;
@end

@implementation VSNotificationBus {
    NSMutableDictionary * _properties;
}

+(id)sharedInstance
{
    static VSNotificationBus * __shared;
    @synchronized(self) {
        if( !__shared )
            __shared = [VSNotificationBus new];
    }
    return __shared;
}

-(id)init
{
    self = [super init];
    if( self )
    {
        _properties = [NSMutableDictionary new];
        _autoDeregister = [NSMutableDictionary new];
    }
    return self;
}

-(void)notify:(NSString *)message obj:(id)obj
{
    // this triggers notifications
    [self setValue:obj forKey:message];
    // ok, notifications are over, lose the reference count on the payloads
    [_properties removeObjectForKey:message];
}

-(id)valueForUndefinedKey:(NSString *)key
{
    return _properties[key];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    _properties[key] = value;
}
@end

@implementation NSObject (VSBroadcasting)

-(void)broadcast:(NSString *)message payload:(id)payload when:(NSTimeInterval)when
{
    if( when )
    {
        [NSObject performBlock:^{
            [self broadcast:message payload:payload];
        } afterDelay:when];
    }
    else
    {
        [self broadcast:message payload:payload];
    }
}

-(void)broadcast:(NSString *)message payload:(id)payload
{
    [[VSNotificationBus sharedInstance] notify:message obj:payload];
}

-(void)registerForBroadcast:(NSString *)message
                            block:(VSBroadcastBlock)block
{
    VSNotificationTokens * tokens = [VSNotificationTokens attachTo:self];

    // if we didn't do this, the ARC could get bumped in the block
    // below and stored that way in addObserver
    //
    // I'm not 100% this isn't a bug waiting to happen when the runtime
    // zero's out the block-captured version of this pointer:
    
    __weak NSObject * me = tokens.target;
    
    NSString * token = [[VSNotificationBus sharedInstance] addObserverForKeyPath:message
                                                                          task:^(VSNotificationBus *notifier)
                        {
                            id payload = [notifier valueForKey:message];
                            block(me,payload);
                        }];
    [tokens.tokens addObject:token];
}

-(void)registerForBroadcasts:(NSArray *)messages
                             block:(VSBroadcastsBlock)block
{
    VSNotificationTokens * tokens = [VSNotificationTokens attachTo:self];
    
    __weak NSObject * me = tokens.target;
    
    NSString * token = [[VSNotificationBus sharedInstance] addObserverForKeyPaths:messages
                                                                             task:^(VSNotificationBus *notifier, NSString *message)
                        {
                            id payload = [notifier valueForKey:message];
                            block(message,me,payload);
                        }];
    
    [tokens.tokens addObject:token];
}


@end


@implementation VSNotificationTokens

+(id)attachTo:(id)target
{
    // this works because associations are really just instance variables
    // (as in: instance variables are almost certainly implemented using
    // associated keys)
    // so they are released when the object is otherwise being dealloc'd
    // that allows us to automatically remove all the
    // observers on the VSNotifications bus
    VSNotificationTokens *tokens = [target associatedValueForKey:kVSRegistrationIdentifiers];

    if( !tokens )
    {
        tokens = [[VSNotificationTokens alloc] init];
        tokens.target = target;
        tokens.tokens = [NSMutableArray new];
        [target associateValue:tokens withKey:kVSRegistrationIdentifiers];
    }
    
    return tokens;
}

-(void)dealloc
{
    VSNotificationBus * notifier = [VSNotificationBus sharedInstance];
    for( NSString * token in _tokens )
    {
        [notifier removeObserversWithIdentifier:token];
    }
}

@end

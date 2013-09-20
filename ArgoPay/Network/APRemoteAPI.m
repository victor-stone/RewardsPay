//
//  APRemoteAPI.m
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteAPI.h"
#import "APRemotableObject.h"
#import "APStrings.h"

// TODO: temp including for mockup
#import "APReward.h"
#import "APMerchant.h"

typedef struct _APRemoteTypeMapping {
    const char * remoteName;
    const char * objCTClassName;
} APRemoteTypeMapping;

static APRemoteTypeMapping _typeMapping[] = {
    { "merchant", "APMerchant" },
    { "reward",   "APReward" },
    { "transaction", "APTransaction" }
};

static const char kNumRemoteMappings = (sizeof(_typeMapping)/sizeof(_typeMapping[0]));

@implementation APRemoteAPI

static void * kRemoteAPIInitializeToken = &kRemoteAPIInitializeToken;

static APRemoteAPI * _shared;

+(id)sharedInstance
{
    @synchronized(self) {
        if( !_shared )
            _shared = [[APRemoteAPI alloc] initWithToken:kRemoteAPIInitializeToken];
    }
    return _shared;
}

-(id)init
{
    NSAssert(0,@"Do not initialize APRemoteAPI. Use +sharedInstance instead\n");
    return nil;
}


-(id)initWithToken:(void *)token
{
    NSAssert(token == kRemoteAPIInitializeToken, @"Illegal initialization of APRemoteAPI. Use +sharedInstance instead");

    self = [super init];
    if( !self ) return nil;
    
    return self;
}


-(void)requestDataFromServer:(NSString *)requestString block:(APRemoteAPIRequestBlock)block
{
    void (^receivedData)(id) = ^(id data) {
        id jsonObj = nil;
        NSError * err = nil;
        jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        // TODO: robustisize error handling
        if(!jsonObj || err)
        {
            NSLog(@"Error: %@", [err localizedDescription]);
            exit(-1);
        }
        NSDictionary * argoObjects = [self convertJSONDictionaryToArgoObjects:jsonObj];        
        block(argoObjects);
    };
    
    NSData * data = nil;
#ifdef DEBUG
    if( APENABLED(kSettingDebugNetworkStubbed) )
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:requestString ofType:@"js"];
        data = [NSData dataWithContentsOfFile:path];
        CGFloat delay = [[NSUserDefaults standardUserDefaults] floatForKey:kSettingDebugNetworkDelay];
        [NSObject performBlock:^{
            receivedData(data);
        } afterDelay:delay];
    }
    else
    {
#endif


#ifdef DEBUG
    }
#endif
}

-(id)convertJSONDictionaryToArgoObjects:(NSDictionary *)dictionary
{
    static NSMutableDictionary * typeMap = nil;
    
    if( !typeMap )
    {
        typeMap = [[NSMutableDictionary alloc] initWithCapacity:kNumRemoteMappings];
        for( int i = 0; i < kNumRemoteMappings; i++ )
        {
            typeMap[@(_typeMapping[i].remoteName)] = NSClassFromString(@(_typeMapping[i].objCTClassName));
        }
    }
    
    NSMutableDictionary * results = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
    dictionary = dictionary[@"rootObj"];
    for( NSString * key in dictionary )
    {
        Class klass = typeMap[key];
        if( klass )
        {
            NSArray * jsonDefinitions = dictionary[key];
            NSMutableArray * argoObjects = [[NSMutableArray alloc] initWithCapacity:jsonDefinitions.count];
            for( NSDictionary * values in jsonDefinitions )
            {
                APRemotableObject * obj = [[klass alloc] initWithDictionary:values];
                [argoObjects addObject:obj];
            }
            results[key] = argoObjects;
        }
    }
    return results;
}

-(void)fixupMerchants:(NSArray *)merchants otherStuff:(NSArray *)other
{
    for( APMerchant * merchant in merchants )
    {
        [self getMerchantImage:[merchant valueForKey:@"logo"] block:^(id data) {
            merchant.logoImg = data;
        }];
    }
    
    for( APRemotableObject * obj in other )
    {
        NSNumber *merchantID = [obj valueForKey:@"merchant_id"];
        for( APMerchant * merchant in merchants )
        {
            if( [merchant.key isEqual:merchantID] )
            {
                [other setValue:merchant forKey:@"merchant"];
                break;
            }
        }
    }
}

-(void)getRewards:(APRemoteAPIRequestBlock)block
{
    // TODO: generalize fixups away from here
    
    [self requestDataFromServer:@"rewards" block:^(id data) {
    
        NSDictionary * dictionary = data;
        NSArray * merchants = dictionary[@"merchant"];
        NSArray * rewards = dictionary[@"reward"];
        [self fixupMerchants:merchants otherStuff:rewards];
        block(rewards);
    }];
    
}

-(void)requestTransaction:(APScanResult *)scanResult block:(APRemoteAPIRequestBlock)block
{
    [self requestDataFromServer:@"transaction" block:^(id data) {        
        NSDictionary * dictionary = data;
        NSArray * merchants = dictionary[@"merchant"];
        NSArray * transArray = dictionary[@"transaction"];
        [self fixupMerchants:merchants otherStuff:transArray];
        block(transArray[0]);
    }];
}

-(void)getMerchantImage:(NSString *)name block:(APRemoteAPIRequestBlock)block;
{
#ifdef DEBUG
    if( APENABLED(kSettingDebugNetworkStubbed) )
    {
        block( [UIImage imageNamed:@"merchantlogo.jpg"] );
    }
    else
    {
#endif
        
        
#ifdef DEBUG
    }
#endif
}

@end

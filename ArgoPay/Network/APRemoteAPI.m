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
    { "transaction", "APTransaction" },
    { "merchantPoints", "APMerchantPoints" }
};

static const char kNumRemoteMappings = (sizeof(_typeMapping)/sizeof(_typeMapping[0]));

@implementation APRemoteAPI

static void * kRemoteAPIInitializeToken = &kRemoteAPIInitializeToken;

static APRemoteAPI * _sharedRemoteAPI;

+(id)sharedInstance
{
    @synchronized(self) {
        if( !_sharedRemoteAPI )
            _sharedRemoteAPI = [[APRemoteAPI alloc] initWithToken:kRemoteAPIInitializeToken];
    }
    return _sharedRemoteAPI;
}

-(NSString *)baseURL
{
#ifdef DEBUG
    return @"http://requestb.in/ytib2eyt";
#else
    return nil;
#endif
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
    void (^receivedData)(id,NSError *) = ^(id data, NSError *err) {
        NSDictionary * argoObjects = nil;
        if( !err )
        {
            id jsonObj = nil;
            err = nil;
            jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if( jsonObj && !err )
                argoObjects = [self convertJSONDictionaryToArgoObjects:jsonObj];
        }
        block(argoObjects,err);
    };
    
    NSData * data = nil;
#ifdef DEBUG
    if( APENABLED(kSettingDebugNetworkStubbed) )
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:requestString ofType:@"js"];
        data = [NSData dataWithContentsOfFile:path];
        CGFloat delay = [[NSUserDefaults standardUserDefaults] floatForKey:kSettingDebugNetworkDelay];
        NSError * error = nil;
        if( [[NSUserDefaults standardUserDefaults] boolForKey:kSettingDebugNetworkSimulatedFail] )
            error = [NSError errorWithDomain:kAPErrorDomain code:0x100 userInfo:@{
                   NSLocalizedDescriptionKey: @"Some kind of (fake) network error"}];
        [NSObject performBlock:^{
            receivedData(data,error);
        } afterDelay:delay];
    }
    else
    {
#endif

        // real network code goes here
        
#ifdef DEBUG
    }
#endif
}

-(void)requestImageFromServer:(NSString *)filename block:(APRemoteAPIRequestBlock)block
{
#ifdef DEBUG
    if( APENABLED(kSettingDebugNetworkStubbed) )
    {
        CGFloat delay = [[NSUserDefaults standardUserDefaults] floatForKey:kSettingDebugNetworkDelay];
        [NSObject performBlock:^{
            NSError * error = nil;
            if( [[NSUserDefaults standardUserDefaults] boolForKey:kSettingDebugNetworkSimulatedFail] )
                error = [NSError errorWithDomain:kAPErrorDomain code:0x100 userInfo:@{}];
            block( [UIImage imageNamed:filename], error );
        } afterDelay:delay];
    }
    else
    {
#endif
        
        // real network code goes here
        
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
        [self getMerchantImage:[merchant valueForKey:@"logo"] block:[^(id data) {
            merchant.logoImg = data;
        } copy]];
    }
    
    for( APRemotableObject * obj in other )
    {
        NSNumber *merchantID = [obj valueForKey:@"merchant_id"];
        for( APMerchant * merchant in merchants )
        {
            if( [merchant.key isEqual:merchantID] )
            {
                [obj setValue:merchant forKey:@"merchant"];
                break;
            }
        }
    }
}

-(void)requestTransaction:(APScanResult *)scanResult block:(APRemoteAPIRequestBlock)block
{
    [self requestDataFromServer:@"transaction" block:^(id data, NSError *err) {
        if( !err )
        {
            NSDictionary * dictionary = data;
            NSArray * merchants = dictionary[@"merchant"];
            NSArray * transArray = dictionary[@"transaction"];
            [self fixupMerchants:merchants otherStuff:transArray];
            data = transArray[0];
        }
        block(data,err);
    }];
}

-(void)getMerchantImage:(NSString *)name block:(APRemoteAPIRequestBlock)block
{
    
#ifdef DEBUG
    if( APENABLED(kSettingDebugNetworkStubbed) )
    {
        name = @"merchantlogo.jpg";
    }
#endif
    
    [self requestImageFromServer:name block:block];
}

-(void)getRewards:(APRemoteAPIRequestBlock)block
{
    [self getRewardsCmd:@"rewards" block:block];
}

-(void)getRewardsCmd:(NSString *)cmd block:(APRemoteAPIRequestBlock)block
{
    // TODO: generalize fixups away from here
    
    [self requestDataFromServer:cmd block:^(id data,NSError *err) {
        if( !err )
        {
            NSDictionary * dictionary = data;
            NSArray * merchants = dictionary[@"merchant"];
            NSArray * rewards = dictionary[@"reward"];
            [self fixupMerchants:merchants otherStuff:rewards];
            data = rewards;
        }
        block(data,err);
    }];
    
}

-(void)redeemArgoPoints:(APReward *)reward block:(APRemoteAPIRequestBlock)block
{
    [self getRewardsCmd:@"reward_redemption" block:block];
    
}

-(void)getMerchantPoints:(APMerchant *)merchant block:(APRemoteAPIRequestBlock)block
{
    [self requestDataFromServer:@"merchant_points" block:^(id data,NSError *err) {
        if( err )
        {
            block(nil,err);
            return;
        }
        NSDictionary * dictionary = data;
        NSArray * points = dictionary[@"merchantPoints"];
        block(points,nil);
    }];
}

-(void)redeemMerchantPoints:(APMerchantPoints *)points block:(APRemoteAPIRequestBlock)block
{
    [self requestDataFromServer:@"merchant_points" block:^(id data,NSError *err) {
        if( err )
        {
            block(nil,err);
            return;
        }
        NSInteger credits = [points.merchant.credits integerValue];
        NSInteger deduct  = [points.points integerValue];
        points.merchant.credits = @(credits - deduct);
        block(points,nil);
    }];
    
}

@end

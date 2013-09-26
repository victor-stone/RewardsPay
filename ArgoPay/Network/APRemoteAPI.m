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
#import "AFNetworking.h"

#ifndef APREMOTESTRINGV
#define APREMOTESTRINGV(type,k,v) NSString * kRemote##type##k = @ #v ;
#endif

#import "APRemoteStrings.h"

// TODO: temp including for mockup
#import "APArgoPointsReward.h"
#import "APMerchant.h"
#import "APTransaction.h"
#import "APOffer.h"

@interface APJSONRequest : AFJSONRequestOperation

@end
@implementation APJSONRequest

-(id)initWithRequest:(NSURLRequest *)urlRequest
{
    self = [super initWithRequest:urlRequest];
    if( self )
        self.JSONReadingOptions = NSJSONReadingAllowFragments;
    return self;
}

@end

@interface APRemoteRepsonse : APRemotableObject
@property (nonatomic,strong) NSNumber *Status;
@property (nonatomic,strong) NSString *Message;
@property (nonatomic,strong) NSString *UserMessage;
@end

@implementation APRemoteRepsonse
@end

@implementation APRemoteAPI {
    NSMutableDictionary *_clients;
}

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

+(NSString *)baseURLForSubDomain:(NSString *)scope
{
#ifdef DEBUG
    NSString * protocol = APENABLED(kSettingDebugNetworkSSL) ? @"https" : @"http";
    NSString * base = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingDebugNetworkStubbed];
#else
    NSString *protocol = @"https";
    NSString * base = @".argopay.com";
#endif
    
    if( [base characterAtIndex:0] == '.' )
        base = [scope stringByAppendingString:base];
    
    return [NSString stringWithFormat:@"%@://%@", protocol, base];
}

+(AFHTTPClient *)clientForSubDomain:(NSString *)subDomain
{
    NSString *urlString = [self baseURLForSubDomain:subDomain];
    APRemoteAPI * api = [APRemoteAPI sharedInstance];
    AFHTTPClient * client = api->_clients[urlString];
    if( !client )
    {
        client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
        [client registerHTTPOperationClass:[APJSONRequest class]];
        [client setDefaultHeader:@"Accept" value:@"text/json"];
        client.parameterEncoding = AFJSONParameterEncoding;
        api->_clients[urlString] = client;
    }
    return client;
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
    
    _clients = [NSMutableDictionary new];
    
    return self;
}


-(void)requestDataFromServer:(NSString *)requestString block:(APRemoteAPIRequestBlock)block
{
    block(nil,[[APError alloc] initWithMsg:@"You're running old code"]);
}

-(void)fixupMerchants:(NSArray *)merchants otherStuff:(NSArray *)other
{
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

-(void)getRewards:(APRemoteAPIRequestBlock)block
{
    [self requestMerchantData:@"rewards"
                   recordName:@"reward"
                        block:block];
}

-(void)requestMerchantData:(NSString *)cmd
                recordName:(NSString *)recordName
                     block:(APRemoteAPIRequestBlock)block
{
    // TODO: generalize fixups away from here
    
    [self requestDataFromServer:cmd block:^(id data,NSError *err) {
        if( !err )
        {
            NSDictionary * dictionary = data;
            NSArray * merchants = dictionary[@"merchant"];
            NSArray * rewards = dictionary[recordName];
            [self fixupMerchants:merchants otherStuff:rewards];
            data = rewards;
        }
        block(data,err);
    }];
    
}

-(void)redeemArgoPoints:(APArgoPointsReward *)reward block:(APRemoteAPIRequestBlock)block
{
    [self requestMerchantData:@"reward_redemption"
                   recordName:@"reward"
                        block:^(NSArray *data, NSError *err) {
                            if( err )
                                block(nil,err);
                            else
                                block(data[0],nil);
                        }];
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

@implementation APRemoteCommand (perform)
-(void)performRequest:(APRemoteAPIRequestBlock)block
{
    AFHTTPClient *client = [APRemoteAPI clientForSubDomain:self.subDomain];
    
    [self willSend];
    
    [client postPath:self.command
          parameters:self.remotableProperties
             success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                 APRemoteRepsonse * response = [[APRemoteRepsonse alloc] initWithDictionary:responseObject];
                 if( [response.Status integerValue] != 0 )
                 {
                     APError *error = [[APError alloc] initWithMsg:response.Message];
                     [self didGetError:error];
                     block(nil,error);
                 }
                 else
                 {
                     Class klass = self.payloadClass;
                     NSString *payloadName = self.payloadName;
                     if( payloadName )
                     {
                         NSMutableArray *remotableObjects = [NSMutableArray new];
                         NSArray *dictionaries = [responseObject valueForKey:payloadName];
                         for( NSDictionary *dictionary in dictionaries)
                         {
                             APRemotableObject *instance = [[klass alloc] initWithDictionary:dictionary];
                             [self didGetResponse:instance];
                             [remotableObjects addObject:instance];
                         }
                         block(remotableObjects,nil);
                     }
                     else
                     {
                         APRemotableObject *instance = [[klass alloc] initWithDictionary:responseObject];
                         [self didGetResponse:instance];
                         block(instance,nil);
                     }
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [self didGetError:error];
                 block(nil,error);
             }];
}
@end

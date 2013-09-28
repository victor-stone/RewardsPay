//
//  APRemoteAPI.m
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

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

@interface APRemoteAPI : NSObject

+(id)sharedInstance;

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
    if( [base isEqualToString:@"localhost"] )
        base = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingDebugLocalhostAddr];
    else if( [base isEqualToString:@"file"] )
        protocol = @"file";
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
    NSURL * url = [NSURL URLWithString:urlString];
#ifdef DEBUG
    if( url.isFileURL )
        return nil;
#endif
    APRemoteAPI * api = [APRemoteAPI sharedInstance];
    AFHTTPClient * client = api->_clients[urlString];
    if( !client )
    {
        client = [[AFHTTPClient alloc] initWithBaseURL:url];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Accept" value:@"text/json"];
        client.parameterEncoding = AFJSONParameterEncoding;
        api->_clients[urlString] = client;
        APLOG(kDebugNetwork, @"Created HTTP-JSON client for base URL: %@", urlString);
    }
    return client;
}

-(id)initWithToken:(void *)token
{
    NSAssert(token == kRemoteAPIInitializeToken, @"Illegal initialization of APRemoteAPI. Use +sharedInstance instead");

    self = [super init];
    if( !self ) return nil;
    
    _clients = [NSMutableDictionary new];
    
#ifdef DEBUG
    [self registerForBroadcast:kNotifyUserSettingChanged block:^(APRemoteAPI *me, NSDictionary *info)
     {
        for( NSString *key in info )
        {
            if( [key isEqualToString:kSettingDebugNetworkStubbed] )
            {
                APLOG(kDebugNetwork, @"Resetting network access stub to:%@", info[key] );
                me->_clients = [NSMutableDictionary new];
                break;
            }
        }
     }];
#endif
    
    return self;
}

@end

@implementation APRemoteCommand (perform)

#ifdef DEBUG

#define DOVALIDATION(obj) [self validateReceipt:obj]

-(id)validateReceipt:(APRemotableObject *)obj
{
    if( [self.command isEqualToString:kRemoteCmdConsumerLogin] )
        return obj;
    
    BOOL strict = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingDebugStrictJSON];
    NSArray *keyPaths = [obj keyPaths];
    
    for( NSString *key in keyPaths )
    {
        if( [obj valueForKey:key] == nil )
        {
            if( strict )
                NSAssert(0,@"Never received %@:%@ value from JSON server", self.command,key);
            else
                APLOG(kDebugFire,@"Never received %@:%@ value from JSON server",self.command,key);
        }
    }
    return self;
}

#else

#define DOVALIDATION(obj)

#endif

#ifdef DEBUG

-(void)performRequest:(APRemoteAPIRequestBlock)block
{
    CGFloat delay = [[NSUserDefaults standardUserDefaults] floatForKey:kSettingDebugNetworkDelay];
    if( delay > 0.001 )
    {
        [NSObject performBlock:^{
            [self _performRequest:block];
        } afterDelay:delay];
    }
    else
    {
        [self _performRequest:block];
    }
}

-(void)_performRequest:(APRemoteAPIRequestBlock)block
{

#else
-(void)performRequest:(APRemoteAPIRequestBlock)block
{

#endif
    AFHTTPClient *client = [APRemoteAPI clientForSubDomain:self.subDomain];
    
    [self willSend];
    
    APLOG(kDebugNetwork, @"Posting: %@ %@", self.command, self.remotableProperties);
    
    void (^parseJSON)(NSDictionary *,APRemoteAPIRequestBlock) = ^(NSDictionary *responseObject,APRemoteAPIRequestBlock block)
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
                DOVALIDATION(instance);
                [remotableObjects addObject:instance];
            }
            block( remotableObjects,nil);
        }
        else
        {
            APRemotableObject *instance = [[klass alloc] initWithDictionary:responseObject];
            [self didGetResponse:instance];
            DOVALIDATION(instance);
            block(instance,nil);
        }
    };
    
#ifdef DEBUG
    if( !client )
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:self.command ofType:@"js"];
        APLOG(kDebugNetwork, @"Using JSON file stubs: %@",path);
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        id jsonObj = nil;
        NSError * err = nil;
        jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if( err )
            block(nil,err);
        else
            parseJSON(jsonObj,block);
        return;
    }
#endif
    
    [client postPath:self.command
          parameters:self.remotableProperties
             success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                 APRemoteRepsonse * response = [[APRemoteRepsonse alloc] initWithDictionary:responseObject];
                 APLOG(kDebugNetwork, @"Repsonse: Status: %@\n    Msg: %@\n   UMsg: %@\n  count: %d\n rawParams:%@",
                       response.Status,
                       response.Message,
                       response.UserMessage,
                       [[responseObject allKeys] count],
                       responseObject[@"rawPostData"]
                       );
                 if( [response.Status integerValue] != 0 )
                 {
                     APError *error = [[APError alloc] initWithMsg:response.Message];
                     [self didGetError:error];
                     block(nil,error);
                 }
                 else
                 {
                     parseJSON(responseObject,block);
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 APLOG(kDebugFire, @"Network error: %@\nResponse text: %@", error, operation.responseString);
                 [self didGetError:error];
                 block(nil,error);
             }];
}
@end

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
    
    return self;
}

@end

@implementation APRemoteCommand (perform)
-(void)performRequest:(APRemoteAPIRequestBlock)block
{
    AFHTTPClient *client = [APRemoteAPI clientForSubDomain:self.subDomain];
    
    [self willSend];
    
    APLOG(kDebugNetwork, @"Posting: %@ %@", self.command, self.remotableProperties);
    
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
                 APLOG(kDebugFire, @"Network error: %@\nResponse text: %@", error, operation.responseString);
                 [self didGetError:error];
                 block(nil,error);
             }];
}
@end

//
//  APRemoteAPI.m
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteObject.h"
#import "APStrings.h"
#import "AFNetworking.h"

#ifndef APREMOTESTRINGV
#define APREMOTESTRINGV(type,k,v) NSString * kRemote##type##k = @ #v ;
#endif

#import "APRemoteStrings.h"

@interface APArgoRequest : AFJSONRequestOperation
@end

@implementation APArgoRequest


-(id)initWithRequest:(NSURLRequest *)urlRequest
{
    self = [super initWithRequest:urlRequest];
    if( self )
    {
        [self setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection,
                                                                  NSURLAuthenticationChallenge *challenge)
        {
            if( [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            {
                SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
#if 0
                NSString * argoPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
                NSData * argoCertData = [NSData dataWithContentsOfFile:argoPath];
                NSString * caPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];
                NSData * caData = [NSData dataWithContentsOfFile:caPath];
                
                CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
                for (CFIndex i = 0; i < certificateCount; i++)
                {
                    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
                    NSData * serverCertData = (__bridge_transfer NSData *)SecCertificateCopyData(certificate);
                    if( [argoCertData isEqualToData:serverCertData] || [caData isEqualToData:serverCertData] )
#endif
                    {
                        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                        return;
                    }
#if 0
                }
#endif
            }
            else if( [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
            {
                NSString *p12Path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
                NSData *p12Data = [[NSData alloc] initWithContentsOfFile:p12Path];
                CFArrayRef p12Items;
                
                NSDictionary * optionsDictionary = @{ (__bridge id)kSecImportExportPassphrase: @"ArgoPay" };
                OSStatus result = SecPKCS12Import((__bridge CFDataRef)p12Data,
                                                  (__bridge CFDictionaryRef)optionsDictionary,
                                                  &p12Items);
                
                
                if(result == noErr)
                {
                    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(p12Items, 0);
                    SecIdentityRef identityApp =(SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
                    
                    SecCertificateRef certRef;
                    SecIdentityCopyCertificate(identityApp, &certRef);
                    
                    SecCertificateRef certArray[1] = { certRef };
                    CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
                    CFRelease(certRef);
                    
                    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identityApp
                                                                             certificates:(__bridge id)myCerts
                                                                              persistence:NSURLCredentialPersistencePermanent];
                    CFRelease(myCerts);
                    
                    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                    return;
                }
            }
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            
        }];
    }
    return self;
}

+ (OSStatus) extractIdentityAndTrust:(CFDataRef)inpfxdata identity:(SecIdentityRef *)identity trust:(SecTrustRef *)trust
{
    OSStatus securityError = errSecSuccess;
    
    CFArrayRef items = NULL;

    const void * keys[] = { kSecImportExportPassphrase };
    const void * values[] = { (CFStringRef)@"ArgoPay" };
    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys, values,1,NULL,NULL);
    securityError = SecPKCS12Import(inpfxdata, dict, &items);
    if (securityError == 0)
    {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity           = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        const void *tempTrust              = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        
        CFRetain(tempIdentity);
        CFRetain(tempTrust);
        
        *identity = (SecIdentityRef)tempIdentity;
        *trust = (SecTrustRef)tempTrust;
    }
    
    CFRelease(items);
    
    return securityError;
}
@end

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
#ifdef ALLOW_DEBUG_SETTINGS
    BOOL ssl = APENABLED(kSettingDebugNetworkSSL);
    NSString * protocol = ssl ? @"https" : @"http";
    NSString * port = ssl ? @":443" : @"";
    NSString * base = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingDebugNetworkStubbed];
    if( [base isEqualToString:@"localhost"] )
        base = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingDebugLocalhostAddr];
    else if( [base isEqualToString:@"file"] )
        protocol = @"file";
#else
    NSString * protocol = @"https";
    NSString * base = @".argopay.com";
    NSString * port = @":443";
#endif
    
    if( [base characterAtIndex:0] == '.' )
        base = [scope stringByAppendingString:base];
    
    return [NSString stringWithFormat:@"%@://%@%@", protocol, base, port];
}

+(AFHTTPClient *)clientForSubDomain:(NSString *)subDomain
{
    NSString *urlString = [self baseURLForSubDomain:subDomain];
    NSURL * url = [NSURL URLWithString:urlString];
#ifdef ALLOW_DEBUG_SETTINGS
    if( url.isFileURL )
        return nil;
#endif
    APRemoteAPI * api = [APRemoteAPI sharedInstance];
    AFHTTPClient * client = api->_clients[urlString];
    if( !client )
    {
        client = [[AFHTTPClient alloc] initWithBaseURL:url];
        [client registerHTTPOperationClass:[APArgoRequest class]];
        [client setDefaultHeader:@"Accept" value:@"text/json"];
        client.parameterEncoding = AFJSONParameterEncoding;
#ifdef ALLOW_DEBUG_SETTINGS
        BOOL ssl = APENABLED(kSettingDebugNetworkSSL);
        if( ssl )
        {
//            client.defaultSSLPinningMode = AFSSLPinningModePublicKey;
            client.defaultSSLPinningMode = AFSSLPinningModeCertificate;
            client.allowsInvalidSSLCertificate = YES;

        }
#else
        client.defaultSSLPinningMode = AFSSLPinningModeCertificate;        
#endif
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

@implementation APRemoteRequest (perform)

-(void)performRequest:(APRemoteAPIRequestBlock)block
{
    [self performRequest:block errorHandler:nil];
}

#ifdef ALLOW_DEBUG_SETTINGS

#define DOVALIDATION(obj) [self validateReceipt:obj]

-(id)validateReceipt:(APRemoteObject *)obj
{
    if( [self.command isEqualToString:kRemoteCmdConsumerLogin] )
        return obj;
    
    BOOL strict = APENABLED(kSettingDebugStrictJSON);
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

-(void)performRequest:(APRemoteAPIRequestBlock)block errorHandler:(APRemoteAPIRequestErrorBlock)errorHandler
{
    CGFloat delay = [[NSUserDefaults standardUserDefaults] floatForKey:kSettingDebugNetworkDelay];
    if( delay > 0.001 )
    {
        APLOG(kDebugNetwork, @"Network bakedin delay: %f", delay);
        [NSObject performBlock:^{
            [self _performRequest:block errorHandler:errorHandler];
        } afterDelay:delay];
    }
    else
    {
        [self _performRequest:block errorHandler:errorHandler];
    }
}

-(void)_performRequest:(APRemoteAPIRequestBlock)block errorHandler:(APRemoteAPIRequestErrorBlock)errorHandler
{
    if( APENABLED(kSettingDebugSendStubData) )
    {
        static NSDictionary * fakeData = nil;
        
        if( !fakeData )
        {
            NSString * path = [[NSBundle mainBundle] pathForResource:@"SendingStubs" ofType:@"plist"];
            fakeData = [NSDictionary dictionaryWithContentsOfFile:path];
        }
        
        NSDictionary * fakeParameters = fakeData[self.command];
        
        if( fakeParameters )
            [self setValuesForKeysWithDictionary:fakeParameters];
    }

    [APRemoteAPI sharedInstance];
    
#else
    
#define DOVALIDATION(obj)

-(void)performRequest:(APRemoteAPIRequestBlock)block errorHandler:(APRemoteAPIRequestErrorBlock)errorHandler
{

#endif
    
    AFHTTPClient *client = [APRemoteAPI clientForSubDomain:self.subDomain];
    
    APLOG(kDebugNetwork, @"Posting: %@{%@} %@", self.command, self.payloadName, self.remotableProperties);
    
    void (^parseJSON)(NSDictionary *,APRemoteAPIRequestBlock) = ^(NSDictionary *responseObject,APRemoteAPIRequestBlock block)
    {
        //
        // Terminology: 'objectify' means map a JSON derived NSDictionary to some
        //              derivation of APRemoteObject
        //
        // This is NOT a general routine for parsing json objects
        //
        // It assumes the shape of response object is one of these:
        //
        // 1. A flat object ('Root')
        //
        // 1a. A flat object that has some members that are NSArrays
        //     that need to be objectified
        //
        // 2. An object with a single array and the caller is only
        //    interested in that array
        //
        // For case (1) the self.paths property will have
        // the flat object's Class under the ROOT key.
        //
        // For case (1a) the self.paths propety will also have
        // the name of members it cares about and relevent Class
        // objects for the array elements.
        //
        // For case (2) the self.paths property will NOT have a ROOT
        // key and simply the name of the root object's member
        // that has the relevant array.
        //
        APRemoteObject *rootObject = nil;
        NSDictionary   *paths      = self.paths;

        Class klass = paths[kRemotePayloadROOT];
        if( klass )
        {
            // Case (1), maybe (1a)
            // The 'responseObject' is the object we want to return
            rootObject = [[klass alloc] initWithDictionary:responseObject];
        }
        
        for( NSString *payloadName in paths )
        {
            if( payloadName != kRemotePayloadROOT )
            {
                // may be case (1a), maybe (2)
                klass = paths[payloadName];
                NSArray *dictionaries = [responseObject valueForKey:payloadName];
                NSMutableArray *remotableObjects = [NSMutableArray new];
                for( NSDictionary *dictionary in dictionaries)
                {
                    APRemoteObject *instance = [[klass alloc] initWithDictionary:dictionary];
                    DOVALIDATION(instance);
                    [remotableObjects addObject:instance];
                }
                if( rootObject )
                {
                    // definitely case (1a)
                    [rootObject setValue:remotableObjects forKey:payloadName];
                }
                else
                {
                    // definitely case (2)
                    block( remotableObjects );
                    // we're done
                    break;
                }
            }
        }

        if( rootObject )
        {
            DOVALIDATION(rootObject);
            block(rootObject);
        }
    };
    
#ifdef ALLOW_DEBUG_SETTINGS
    if( !client )
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:self.command ofType:@"js"];
        APLOG(kDebugNetwork, @"Using JSON file stubs: %@",path);
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSError * err = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if( err )
        {
            if( errorHandler )
            {
                errorHandler(err);
            }
            else
            {
                [self broadcast:kNotifySystemError payload:err];
            }
        }
        else
        {
            parseJSON(jsonObj,block);
        }
        return;
    }
#endif
    
    [client postPath:self.command
          parameters:self.remotableProperties
             success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
    {
        APLOG(kDebugJSONDumps, @"SENT: %@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        APLOG(kDebugJSONDumps, @"RECEIVED: %@", operation.responseString);
        APRemoteRepsonse * response = [[APRemoteRepsonse alloc] initWithDictionary:responseObject];
        APLOG(kDebugNetwork, @"Response: Status: %@\n    Msg: %@\n   UMsg: %@\n  count: %d\n rawParams:%@",
              response.Status,
              response.Message,
              response.UserMessage,
              [[responseObject allKeys] count],
              responseObject[@"rawPostData"]
              );
        if( [response.Status integerValue] != 0 )
        {
            APError *error = [APError errorWithMsg:response.Message serverStatus:[response.Status integerValue]];
            if( errorHandler )
            {
                errorHandler(error);
            }
            else
            {
                [self broadcast:kNotifySystemError payload:error];
            }
        }
        else
        {
            parseJSON(responseObject,block);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        APLOG(kDebugFire, @"Network error: %@\nResponse text: %@", error, operation.responseString);
        if( errorHandler )
        {
            errorHandler(error);
        }
        else
        {
            [self broadcast:kNotifySystemError payload:error];
        }
    }];
}
@end

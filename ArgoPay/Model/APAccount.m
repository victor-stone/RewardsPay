//
//  APAccount.m
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APAccount.h"
#import "APStrings.h"
#import "APRemoteStrings.h"

/*
 /ConsumerLogin
 > Email, Password, InToken
 < Status, Message, AToken, AccountID
 */
@interface APRequestLogin : APRemoteRequest
@property (nonatomic,strong) NSString *UserName;
@property (nonatomic,strong) NSString *Password;
@property (nonatomic,strong) NSString *InToken;
@end


@implementation APAccount

static APAccount * __currentAccount;

APLOGRELEASE

+(id)currentAccount
{
    return __currentAccount;
}

+(void)login:(NSString *)loginUserName
    password:(NSString *)password
       block:(APRemoteAPIRequestBlock)block
{
    // um, in case of error...
    __currentAccount = [APAccount new];
    
    APRequestLogin *loginRequest = [APRequestLogin new];
    loginRequest.UserName      = loginUserName;
    loginRequest.Password   = password;
    loginRequest.InToken    = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingUserUniqueID];
    if( (loginRequest.UserName.length == 0) || (loginRequest.Password.length == 0 ) )
    {
        APError *appError = [APError errorWithCode:kAPERROR_MISSINGLOGINFIELDS];
        [appError broadcast:kNotifySystemError payload:appError];
        return;
    }
    
    [loginRequest performRequest:^(APAccount * account) {
        APLOG(kDebugUser, @"User is logged with AToken: %@",account.AToken);
        __currentAccount = account;
        __currentAccount.login = loginRequest.UserName;
        __currentAccount.password = loginRequest.Password;
        block(account);
    } errorHandler:^(NSError *err) {
        block(nil);
        [err broadcast:kNotifySystemError payload:err];
    }];
}

+(void)loginWithUserName:(NSString *)userName andToken:(NSString *)AToken
{
    __currentAccount = [APAccount new];
    __currentAccount.login = userName;
    __currentAccount.AToken = AToken;
    APLOG(kDebugUser, @"User is logged with AToken: %@",AToken);
}

-(void)setLogin:(NSString *)login
{
    _login = login;
}

-(void)setPassword:(NSString *)password
{
    _password = password;
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kSettingUserLoginPassword];
}

-(void)logUserOut
{
    /*
     We are using the UserDefaults for QuickScan login
    self.login = nil;
    self.password = nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
     */
    
    _AToken = nil;
    APLOG(kDebugUser, @"User account logged out", 0);
    [self broadcast:kNotifyUserLoginStatus payload:self];
}

-(BOOL)isLoggedIn
{
    return _AToken != nil;
}
@end

@implementation APRequestLogin

-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerLogin
                    subDomain:kRemoteSubDomainCustomer];
}

-(Class)payloadClass
{
    return [APAccount class];
}
@end

@implementation APRequestChangePassword
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerChangePassword subDomain:kRemoteSubDomainCustomer];
}
@end

@implementation APRequestStatementSummary
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerStatementSummary
                    subDomain:kRemoteSubDomainCustomer];
}

-(Class)payloadClass
{
    return [APAccountSummary class];
}
@end

@implementation APAccountSummary
@end

@implementation APRequestStatementDetail

-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerStatementDetail
                    subDomain:kRemoteSubDomainCustomer];
}

-(Class)payloadClass
{
    return [APStatementLine class];
}

-(NSString *)payloadName
{
    return kRemotePayloadTransactions;
}
@end

@implementation APStatementLine
@end

@implementation APRequestValidateGet
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerValidateGet subDomain:kRemoteSubDomainCustomer];
}

-(Class)payloadClass
{
    return [APValidateGet class];
}
@end

@implementation APValidateGet
@end

@implementation APRequestValidateTest
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerValidateTest subDomain:kRemoteSubDomainCustomer];
}

-(Class)payloadClass
{
    return [APValidateTest class];
}
@end

@implementation APValidateTest
@end

@implementation APRequestSetPIN
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerSetPIN subDomain:kRemoteSubDomainCustomer];
}
@end

@implementation APRequestSetPINRequired
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerSetPINRequired subDomain:kRemoteSubDomainCustomer];
}
@end

@implementation APResponseGetPinRequired
@end

@implementation APRequestGetPinRequired
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerGetPINRequired subDomain:kRemoteSubDomainCustomer];
}
-(Class)payloadClass
{
    return [APResponseGetPinRequired class];
}
@end

@implementation APRequestSetNotificationID
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerSetNotificationID subDomain:kRemoteSubDomainCustomer];
}
@end

@implementation APRequestSetNotificationEnabled
-(id)init
{
    return [super initWithCmd:kRemoteCmdConsumerSetNotificationEnabled subDomain:kRemoteSubDomainCustomer];
}
@end
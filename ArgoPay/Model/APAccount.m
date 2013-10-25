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
@property (nonatomic,strong) NSString *Email;
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

+(void)login:(NSString *)loginEmail
    password:(NSString *)password
       block:(APRemoteAPIRequestBlock)block
{
    // um, in case of error...
    __currentAccount = [APAccount new];
    
    APRequestLogin *loginRequest = [APRequestLogin new];
    loginRequest.Email      = loginEmail;
    loginRequest.Password   = password;
    loginRequest.InToken    = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingUserUniqueID];
    if( (loginRequest.Email.length == 0) || (loginRequest.Password.length == 0 ) )
    {
        APError *appError = [APError errorWithCode:kAPERROR_MISSINGLOGINFIELDS];
        [appError broadcast:kNotifySystemError payload:appError];
        return;
    }
    
    [loginRequest performRequest:^(APAccount *account) {
        APLOG(kDebugUser, @"User is logged with AToken: %@",account.AToken);
        __currentAccount = account;
        __currentAccount.login = loginRequest.Email;
        __currentAccount.password = loginRequest.Password;
        block(account);
        [self broadcast:kNotifyUserLoginStatus payload:self];
    }];
}

+(void)attempLoginWithDefaults:(APRemoteAPIRequestBlock)block
{
    // um, in case of error...
    __currentAccount = [APAccount new];
    
    APRequestLogin *loginRequest = [APRequestLogin new];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    loginRequest.Email      = [settings stringForKey:kSettingUserLoginName];
    loginRequest.Password   = [settings stringForKey:kSettingUserLoginPassword];
    loginRequest.InToken    = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingUserUniqueID];

    APLOG(kDebugUser, @"Attemping login with username: %@ password: %@", loginRequest.Email, loginRequest.Password);
    if( (loginRequest.Email.length == 0) || (loginRequest.Password.length == 0 ) )
    {
        block(nil);
        return;
    }
    
    [loginRequest performRequest:^(APAccount *account) {
        APLOG(kDebugUser, @"User is logged with AToken: %@",account.AToken);
        __currentAccount = account;
        __currentAccount.login = loginRequest.Email;
        __currentAccount.password = loginRequest.Password;
        block(account);
       // [self broadcast:kNotifyUserLoginStatus payload:self];
    }];
}

-(void)setLogin:(NSString *)login
{
    _login = login;
    [[NSUserDefaults standardUserDefaults] setValue:login forKey:kSettingUserLoginName];
}

-(void)setPassword:(NSString *)password
{
    _password = password;
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kSettingUserLoginPassword];
}

-(void)logUserOut
{
    self.login = nil;
    self.password = nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
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

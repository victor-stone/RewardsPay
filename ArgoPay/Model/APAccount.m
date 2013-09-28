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
@interface APAccountLogin : APRemoteCommand
@property (nonatomic,strong) NSString *Email;
@property (nonatomic,strong) NSString *Password;
@property (nonatomic,strong) NSString *InToken;
@end


@implementation APAccount

static APAccount * __currentAccount;

+(id)currentAccount
{
    return __currentAccount;
}

+(void)login:(NSString *)loginEmail
    password:(NSString *)password
       block:(APRemoteAPIRequestBlock)block
{
    APAccountLogin *loginRequest = [APAccountLogin new];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    loginRequest.Email      = loginEmail ?: [settings stringForKey:kSettingUserLoginName];
    loginRequest.Password   = password ?: [settings stringForKey:kSettingUserLoginPassword];
    loginRequest.InToken    = @"Hey Reed, What exactly should I be sending here?";

    APLOG(kDebugUser, @"Attemping login with username: %@ password: %@", loginRequest.Email, loginRequest.Password);
    
    APRemoteAPIRequestBlock handleAccount = ^(APAccount *account, NSError *err) {
        if( !account )
        {
            APLOG(kDebugUser, @"No user account returned, creating blank", 0)
            account = [APAccount new];
        }
        else
        {
            APLOG(kDebugUser, @"User is logged with AToken: %@",account.AToken);
        }
        __currentAccount = account;
        __currentAccount.login = loginRequest.Email;
        __currentAccount.password = loginRequest.Password;
        if( block )
        {
            if( err )
                block(nil,err);
            else
                block(account,nil);
        }
        [self broadcast:kNotifyUserLoginStatusChanged payload:account when:0.2];
    };
    
    if( (loginRequest.Email.length == 0) || (loginRequest.Password.length == 0 ) )
    {
        APError *appError = [[APError alloc] initWithMsg:NSLocalizedString(@"Both login name and password are required to login", @"Account login")];
        handleAccount(nil,appError);
    }
    else
    {
        [loginRequest performRequest:handleAccount];
    }
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

-(void)setArgoPoints:(NSNumber *)argoPoints
{
    _argoPoints = argoPoints;
    [[NSUserDefaults standardUserDefaults] setValue:argoPoints forKey:kSettingUserArgoPoints];
}

-(void)logUserOut
{
    self.login = nil;
    self.password = nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
    _AToken = nil;
    [self broadcast:kNotifyUserLoginStatusChanged payload:self when:0.2];
    APLOG(kDebugUser, @"User account logged out", 0);
}

-(BOOL)isLoggedIn
{
    return _AToken != nil;
}
@end

@implementation APAccountLogin

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

@implementation APAccountSummaryRequest

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

@implementation APStatementRequest

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

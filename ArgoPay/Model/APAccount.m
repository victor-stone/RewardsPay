//
//  APAccount.m
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APAccount.h"
#import "APStrings.h"

@implementation APAccount

static void * kAccountSharedInitToken = &kAccountSharedInitToken;

static APAccount * __sharedAccount;

+(id)sharedInstance
{
    @synchronized(self) {
        if( !__sharedAccount )
            __sharedAccount = [[APAccount alloc] initWithToken:kAccountSharedInitToken];
    }
    return __sharedAccount;
}

-(id)init
{
    NSAssert(0,@"Do not initialize APAccount. Use +sharedInstance instead\n");
    return nil;
}

-(id)initWithToken:(void *)token
{
    NSAssert(token == kAccountSharedInitToken, @"Illegal initialization of APAccount. Use +sharedInstance instead");
    
    self = [super init];
    if( !self ) return nil;
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    _login      = [settings stringForKey:kSettingUserLoginName];
    _password   = [settings stringForKey:kSettingUserLoginPassword];
    _argoPoints = [settings valueForKey:kSettingUserArgoPoints];
    
    return self;
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

-(void)adjustArgoPoint:(NSUInteger)amount
{
    self.argoPoints = @([_argoPoints integerValue] + amount);
}
@end

//
//  APAccount.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"


@interface APAccount : APRemotableObject

@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *AccountID;

@property (nonatomic,strong) NSString * login;
@property (nonatomic,strong) NSString * password;
@property (nonatomic,strong) NSNumber * argoPoints;


+(id)currentAccount;
+(void)login:(NSString *)loginEmail
    password:(NSString *)password
       block:(APRemoteAPIRequestBlock)block;

-(void)logUserOut;
@property (nonatomic,readonly) BOOL isLoggedIn;

@end

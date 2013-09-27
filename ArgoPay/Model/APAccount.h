//
//  APAccount.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"


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

@interface APAccount : APRemotableObject

@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *AccountID;

+(id)sharedInstance;

@property (nonatomic,strong) NSString * login;
@property (nonatomic,strong) NSString * password;
@property (nonatomic,strong) NSNumber * argoPoints;


-(void)logUserOut;
@property (nonatomic,readonly) BOOL isLoggedIn;

@end

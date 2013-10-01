//
//  APAccount.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteObject.h"


@interface APAccount : APRemoteObject

@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *AccountID;

@property (nonatomic,strong) NSString * login;
@property (nonatomic,strong) NSString * password;

+(id)currentAccount;
+(void)login:(NSString *)loginEmail
    password:(NSString *)password
       block:(APRemoteAPIRequestBlock)block;

-(void)logUserOut;
@property (nonatomic,readonly) BOOL isLoggedIn;

@end

/*
 /ConsumerStatementSummary
 >AToken
 <AmountAvailable, AmountOutstanding, LastTransDate, LastPayDate, NextPayDate, NetPayAmount, ArgoPoints
 */
@interface APRequestStatementSummary : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@end


@interface APAccountSummary : APRemoteObject
@property (nonatomic,strong) NSNumber *AmountAvailable;
@property (nonatomic,strong) NSNumber *AmountOutstanding;
@property (nonatomic,strong) NSString *LastTransDate;
@property (nonatomic,strong) NSString *LastPayDate;
@property (nonatomic,strong) NSString *NextPayDate;
@property (nonatomic,strong) NSNumber *NetPayAmount;
@property (nonatomic,strong) NSNumber *ArgoPoints;
@end


/*
 /ConsumerStatementDetail
 >AToken, DateFrom, DateTo
 <Status, Message, Transactions {Date, Type, Amount, AmountUnpaid, Description}
*/

@interface APRequestStatementDetail : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *DateFrom;
@property (nonatomic,strong) NSString *DateTo;
@end

@interface APStatementLine : APRemoteObject
@property (nonatomic,strong) NSString *Date;
@property (nonatomic,strong) NSString *Type;
@property (nonatomic,strong) NSString *Description;
@property (nonatomic,strong) NSNumber *Amount;
@property (nonatomic,strong) NSNumber *AmountUnpaid;
@end
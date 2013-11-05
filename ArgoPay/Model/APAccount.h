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

+(void)login:(NSString *)loginUserName
    password:(NSString *)password
       block:(APRemoteAPIRequestBlock)block;

+(void)loginWithUserName:(NSString *)userName
             andToken:(NSString *)AToken;

-(void)logUserOut;

@property (nonatomic,readonly) BOOL isLoggedIn;

@end

/*
 /ConsumerChangePassword
 >AToken, NewPassword
 <Status, Message
 */

@interface APRequestChangePassword : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * NewPassword;
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


/*
 /ConsumerValidateGet (Gets consumer protection questions.  Consumer does not need to be logged in)
 > Email
 < Status, Message, Ques1, Ques2, Ques3
*/
@interface APRequestValidateGet : APRemoteRequest
@property (nonatomic,strong) NSString * UserName;
@end

@interface APValidateGet : APRemoteObject
@property (nonatomic,strong) NSString * Ques1;
@property (nonatomic,strong) NSString * Ques2;
@property (nonatomic,strong) NSString * Ques3;
@end

/*
 /ConsumerValidateTest (Send answers for verification to server. If successful, logs in consumer)
 > Email, Ans1, Ans2, Ans3
 < Status, Message, AToken, AccountID
*/

@interface APRequestValidateTest : APRemoteRequest
@property (nonatomic,strong) NSString * UserName;
@property (nonatomic,strong) NSString * Ans1;
@property (nonatomic,strong) NSString * Ans2;
@property (nonatomic,strong) NSString * Ans3;
@end

@interface APValidateTest : APRemoteObject
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * AccountID;
@end


/*
 /ConsumerSetPIN (Sets a Consumer PIN for verifying transactions)
 >AToken, PIN
 <Status, Message
*/

@interface APRequestSetPIN : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * PIN;
@end

/*
 /ConsumerGetPINRequired (Gets whether a PIN is required)
 >AToken
 <Status, Message, PINRequired
 */

@interface APRequestGetPinRequired : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@end

@interface APResponseGetPinRequired : APRemoteObject
@property (nonatomic,strong) NSString * PINRequired;
@end


/*
 /ConsumerSetPINRequired (Allows a user to require a PIN)
 >AToken, PINRequred (Y/N)
 <Status, Message
*/

@interface APRequestSetPINRequired : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * PINRequired;
@end

/*
 /ConsumerSetNotificationID
 >AToken, ID
 <Status, Message
*/

@interface APRequestSetNotificationID : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * ID;
@end


/*
 /ConsumerSetNotificatonEnabled
 >AToken, Enabled (Y/N)
 <Status, Message
*/

@interface APRequestSetNotificationEnabled : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * Enabled;
@end

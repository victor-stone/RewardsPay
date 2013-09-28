//
//  APTransactionResult.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteObject.h"

/*
 /ConsumerTransactionStart
 > AToken, QrData, Lat, Long, PayID
 < Status, Message, TransID 
*/
@interface APTransactionStartRequest : APRemoteCommand
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * QrData;
@property (nonatomic,strong) NSString * PayID; // always null for now
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@end

@interface APTransactionIDResponse : APRemoteObject
@property (nonatomic,strong) NSString *TransID;
@end

/*
 /ConsumerTransactionStatus
 >AToken, TransID
 <  Status, Message, TransStatus, Amounts: {Type,Amount),
    TotalAmount, PayAmounts: {Desc, Amount}, 
    MerchName, MerchLocation, MerchRegister
 
 Then you call this message.  It will either return immediately or after a period of time with:
 -  T for time (the transaction did not happen because the register did not do it in time)
 In this case, you need to tell the user that the transaction failed for some reason
 -  P for Pending (the transaction is still awaiting the register to do its part
 In this case, just resend the same message again.
 -  A for Approve?
 In this case you give the screen that allows approval, the amounts will be listed in the response
 -  I insufficient credit
 Tell the user that they do not have enough credit available to make the purchase.  the amounts will be listed
 -  C for Cancelled.  The merchant or consumer cancelled the transaction
 Tell the user that the transaction has been cancelled */

@interface APTransactionStatusRequest : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *TransID;
@end


@interface APTransactionStatusResponse : APRemoteObject
@property (nonatomic,strong) NSString *TransStatus;
@property (nonatomic,strong) NSArray *Amounts; // @{ 'Type':'', 'Amount':'' }
@property (nonatomic,strong) NSNumber *TotalAmount;
@property (nonatomic,strong) NSArray *PayAmounts; // @{ 'Desc': 'Amount': '' }
@property (nonatomic,strong) NSString *MerchName;
@property (nonatomic,strong) NSString *MerchLocation;
@property (nonatomic,strong) NSString *MerchRegister;
@end

/*

 /ConsumerTransactionApprove
 >AToken, TransID, Approve (Binary [Y/N])
 <Status, Message, UserMessage
 */
@interface APTransactionApprovalRequest : APRemoteCommand
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *TransID;
@property (nonatomic,strong) NSString *Approve;
@end


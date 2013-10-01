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
@interface APRequestTransactionStart : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * QrData;
@property (nonatomic,strong) NSString * PayID; // always null for now
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@end

@interface APTransactionIDResponse : APRemoteObject
@property (nonatomic,strong) NSString *TransID;
@end

@interface APRequestTransactionStatus : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *TransID;
@end

/*
 <Status, Message, TransStatus, Amounts: {Type,Amount), TotalAmount, 
 PayAmounts: {Desc, Amount}, MerchName, MerchLocation, MerchRegister
 */
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
@interface APRequestTransactionApprove : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *TransID;
@property (nonatomic,strong) NSString *Approve;
@end


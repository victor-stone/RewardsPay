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
 < Status, Message, TransID, PINRequired
*/
@interface APRequestTransactionStart : APRemoteRequest
@property (nonatomic,strong) NSString * AToken;
@property (nonatomic,strong) NSString * QrData;
@property (nonatomic,strong) NSNumber * PayID; // always null for now
@property (nonatomic,strong) NSNumber *Lat;
@property (nonatomic,strong) NSNumber *Long;
@end

@interface APTransactionIDResponse : APRemoteObject
@property (nonatomic,strong) NSString *TransID;
@property (nonatomic,strong) NSString *PINRequired;
@end

@interface APRequestTransactionStatus : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *TransID;
@end

/*
 <Status, Message, TransStatus, Amounts: {Type,Amount), TotalAmount, 
 PayAmounts: {Desc, Amount}, MerchName, MerchLocation, MerchRegister
 */
@interface APTransactionStatusResponse : APRemoteRepsonse
@property (nonatomic,strong) NSString *TransStatus;
@property (nonatomic,strong) NSArray *Amounts; // @{ 'Type':'', 'Amount':'' }
@property (nonatomic,strong) NSNumber *TotalAmount;
@property (nonatomic,strong) NSArray *PayAmounts; // @{ 'Desc': 'Amount': '' }
@property (nonatomic,strong) NSString *MerchName;
@property (nonatomic,strong) NSString *MerchLocation;
@property (nonatomic,strong) NSString *MerchRegister;
@property (nonatomic,strong) NSString *Category;
@end

/*

 /ConsumerTransactionApprove
 >AToken, TransID, Approve (Binary [Y/N]), PIN
 <Status, Message, UserMessage
 */
@interface APRequestTransactionApprove : APRemoteRequest
@property (nonatomic,strong) NSString *AToken;
@property (nonatomic,strong) NSString *TransID;
@property (nonatomic,strong) NSString *Approve;
@property (nonatomic,strong) NSString *PIN;
@end


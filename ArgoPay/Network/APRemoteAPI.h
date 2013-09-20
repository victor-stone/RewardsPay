//
//  APRemoteAPI.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APRemoteAPIRequestBlock)(id data);

@class APScanResult;

@interface APRemoteAPI : NSObject

+(id)sharedInstance;

-(void)getRewards:(APRemoteAPIRequestBlock)block;
-(void)getMerchantImage:(NSString *)name block:(APRemoteAPIRequestBlock)block;
-(void)requestTransaction:(APScanResult *)scanResult block:(APRemoteAPIRequestBlock)block;

@end

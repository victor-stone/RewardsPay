//
//  APRemotableObject.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteAPI.h"

#define kRemoteArrayLimit 300

@interface APRemotableObject : NSObject

-(id)initWithDictionary:(NSDictionary *)values;

@property (nonatomic,strong) NSNumber * key;
@end

@interface APRemoteCommand : APRemotableObject
-(id)initWithCmd:(NSString *)cmd subDomain:(NSString *)subDomain;
@property (readonly,nonatomic) NSDictionary *remotableProperties;
@property (readonly,nonatomic) NSString *command;
@property (readonly,nonatomic) NSString *subDomain;
@property (readonly,nonatomic) Class payloadClass;
@property (readonly,nonatomic) NSString *payloadName;

// for derived classes
-(void)willSend;
-(void)didGetResponse:(id)responseObject;
-(void)didGetError:(NSError *)error;
@end

@interface APRemoteCommand (perform)
-(void)performRequest:(APRemoteAPIRequestBlock)block;
@end
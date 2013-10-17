//
//  APRemotableObject.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#define kRemoteArrayLimit 300

typedef void (^APRemoteAPIRequestBlock)(id data);
typedef void (^APRemoteAPIRequestErrorBlock)(NSError *err);


@interface APRemoteObject : NSObject

-(id)initWithDictionary:(NSDictionary *)values;

-(NSString *)formatDateField:(NSString *)nameOfDateField;
-(NSString *)formatDateField:(NSString *)nameOfDateField style:(NSDateFormatterStyle)style;

@end

@interface APRemoteRequest : APRemoteObject
-(id)initWithCmd:(NSString *)cmd subDomain:(NSString *)subDomain;
@property (readonly,nonatomic) NSDictionary *remotableProperties;
@property (readonly,nonatomic) NSString *command;
@property (readonly,nonatomic) NSString *subDomain;
@property (readonly,nonatomic) Class payloadClass;
@property (readonly,nonatomic) NSString *payloadName;
-(NSDictionary *)paths;
@end

@interface APRemoteRequest (perform)
-(void)performRequest:(APRemoteAPIRequestBlock)block;
-(void)performRequest:(APRemoteAPIRequestBlock)block errorHandler:(APRemoteAPIRequestErrorBlock)errorHandler;
@end

// Generic response
@interface APRemoteRepsonse : APRemoteObject
@property (nonatomic,strong) NSNumber *Status;
@property (nonatomic,strong) NSString *Message;
@property (nonatomic,strong) NSString *UserMessage;
@end

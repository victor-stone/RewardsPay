//
//  APAccount.h
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"

@interface APAccount : APRemotableObject

+(id)sharedInstance;

@property (nonatomic,strong) NSString * login;
@property (nonatomic,strong) NSString * password;
@property (nonatomic,strong) NSNumber * argoPoints;

@end

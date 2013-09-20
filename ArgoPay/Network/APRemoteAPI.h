//
//  APRemoteAPI.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APRemoteAPI : NSObject

+(id)sharedInstance;

-(NSArray *)getRewards;

@end

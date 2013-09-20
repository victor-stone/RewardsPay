//
//  APRemoteAPI.m
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemoteAPI.h"

@implementation APRemoteAPI

static void * kRemoteAPIInitializeToken = &kRemoteAPIInitializeToken;

static APRemoteAPI * _shared;

+(id)sharedInstance
{
    @synchronized(self) {
        if( !_shared )
            _shared = [[APRemoteAPI alloc] initWithToken:kRemoteAPIInitializeToken];
    }
    return _shared;
}

-(id)init
{
    printf("Do not initialize APRemoteAPI. Use +sharedInstance instead\n");
    exit(-1);
    return nil;
}


-(id)initWithToken:(void *)token
{
    NSAssert(token == kRemoteAPIInitializeToken, @"Illegal initialization of APRemoteAPI. Use +sharedInstance instead");

    self = [super init];
    if( !self ) return nil;
    
    return self;
}


-(NSArray *)getRewards
{
    return nil;
}

@end

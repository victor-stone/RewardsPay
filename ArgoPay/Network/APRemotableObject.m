//
//  APRemotableObject.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"


static unsigned int __testingCounter = 0;

@implementation APRemotableObject

-(id)init
{
    if( (self = [super init]) == nil )
        return nil;
    
    _key = @(++__testingCounter);
    return self;
}
@end
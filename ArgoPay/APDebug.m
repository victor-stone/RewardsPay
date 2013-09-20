//
//  APDebug.m
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APDebug.h"
#import "APStrings.h"

#ifdef DEBUG

void APDebug(NSString *key,NSString *format,...)
{
    if( [key isEqualToString:kDebugFire] || APENABLED(key) )
    {
        va_list ap;
        va_start (ap, format);
        NSString * str = [[NSString alloc] initWithFormat:format arguments:ap];
        printf("APLog: %s\n",[str UTF8String]);
        va_end (ap);
    }
}

#endif
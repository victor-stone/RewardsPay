//
//  APDebug.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//


#ifdef DEBUG

#define APLOG(key,fmt,...) APDebug(key,fmt,__VA_ARGS__);
#define APLOGRELEASE   -(void) dealloc { APLOG( kDebugLifetime, @"Object released: %@", self ); }
#define APENABLED(key)  [[NSUserDefaults standardUserDefaults] boolForKey:key]

void APDebug(NSString *key,NSString *format,...);

#else

#define APLOG(...)
#define APLOGRELEASE

#endif
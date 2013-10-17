//
//  APDebug.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//


#define APENABLED(key)  ([[NSUserDefaults standardUserDefaults] boolForKey:key] != NO)

#ifdef DEBUG

#define APLOG(key,...) APDebug(key,__VA_ARGS__);

#define APDUMPVIEW(view) APDebugDumpView(view);
#define APDUMPVCS APDebugDumpControllers(nil)

#define APLOGRELEASE   -(void) dealloc { APDebug( kDebugLifetime, @"Object released: %@", self ); }

void APDebug(NSString *key,NSString *format,...);
void APDebugDumpView(UIView *view);
void APDebugDumpControllers(UIViewController *vc);

#else

#define APLOG(...)
#define APDUMPVIEW(view)
#define APLOGRELEASE
#define APDUMPVCS

#endif
//
//  APDebug.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//


#define APENABLED(key)  ([[NSUserDefaults standardUserDefaults] boolForKey:key] != NO)

#ifdef DEBUG

#define APLOG(key,fmt,...) APDebug(key,fmt,__VA_ARGS__);
#define APDUMPVIEW(view) APDebugDumpView(view);
#define APLOGRELEASE   -(void) dealloc { APLOG( kDebugLifetime, @"Object released: %@", self ); }
#define APAPPEARDUMP -(void) viewDidAppear:(BOOL)animated{ [super viewDidAppear:animated]; APDebugDumpView(self.view); }
#define APDUMPVCS APDebugDumpControllers(nil)

void APDebug(NSString *key,NSString *format,...);
void APDebugDumpView(UIView *view);
void APDebugDumpControllers(UIViewController *vc);

#else

#define APLOG(...)
#define APDUMPVIEW(view)
#define APLOGRELEASE
#define APAPPEARDUMP
#define APDUMPVCS

#endif
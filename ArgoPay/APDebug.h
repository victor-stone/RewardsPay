//
//  APDebug.h
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//


#ifdef DEBUG

#define APENABLED(key)  ([[NSUserDefaults standardUserDefaults] boolForKey:key] != NO)

#define APLOG(key,fmt,...) APDebug(key,fmt,__VA_ARGS__);
#define APDUMPVIEW(view) APDebugDumpView(view);
#define APLOGRELEASE   -(void) dealloc { APLOG( kDebugLifetime, @"Object released: %@", self ); }
#define APAPPEARDUMP -(void) viewDidAppear:(BOOL)animated{ [super viewDidAppear:animated]; APDebugDumpView(self.view); }

void APDebug(NSString *key,NSString *format,...);
void APDebugDumpView(UIView *view);
#else

#define APLOG(...)
#deifne APDUMPVIEW(view)
#define APLOGRELEASE
#define APAPPEARDUMP

#endif
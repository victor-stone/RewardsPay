//
//  APStrings.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#ifdef APKEYEDSTRING
#undef APKEYEDSTRING
#endif

#define APKEYEDSTRING(key) NSString *const key = @ #key;

#include "APStrings.h"


//
//  APMerchant.h
//  ArgoPay
//
//  Created by victor on 9/19/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APRemotableObject.h"

@interface APMerchant : APRemotableObject

@property (nonatomic,strong) UIImage *logo;
@property (nonatomic,strong) UIImage *streetImage;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *zip;
@property (nonatomic,strong) NSString *url;

@end

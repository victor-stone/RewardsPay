//
//  APHomeViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#include "VSTabNavigatorViewController.h"
#import "APDebug.h"
#import "APStrings.h"

@interface APMainViewController : VSTabNavigatorViewController
@property (weak, nonatomic) IBOutlet UIView *orangeBox;
@end

@implementation APMainViewController

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];

    CALayer *layer = _orangeBox.layer;
    layer.cornerRadius = 5.0;
    layer.masksToBounds = YES;
}

@end


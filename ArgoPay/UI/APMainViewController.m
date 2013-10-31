//
//  APHomeViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#include "VSTabNavigatorViewController.h"
#import "APStrings.h"
#import "CustomBadge.h"

@interface APBadgeLabel : CustomBadge
@end

@implementation APBadgeLabel

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithString:@"00" withScale:1.0 withShining:YES];
    if( self )
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

@end
@interface APMainViewController : VSTabNavigatorViewController
@property (weak, nonatomic) IBOutlet APBadgeLabel *placesBadge;
@property (weak, nonatomic) IBOutlet APBadgeLabel *offersBadge;
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
    
    _placesBadge.hidden = YES;
    _offersBadge.hidden = YES;
    
    [self registerForBroadcast:kNotifyMessageFromRemotePush
                         block:^(APMainViewController * me, NSDictionary * aps) {
                             NSString *str = [NSString stringWithFormat:@"%d", [aps[@"aps"][@"badge"] integerValue]];
                             [me->_offersBadge autoBadgeSizeWithString:str];
                             me->_offersBadge.hidden = NO;
                         }];
    [self registerForBroadcast:kNotifyRemotePushPickedUp
                         block:^(APMainViewController * me, id blahFoo) {
                             me->_offersBadge.hidden = YES;
                         }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationEmbedding.backgroundColor = [UIColor argoOrange];
}


@end


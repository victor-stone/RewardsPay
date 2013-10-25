//
//  APHomeViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#include "VSTabNavigatorViewController.h"
#import "APStrings.h"

@interface APBadgeLabel : UILabel
@end
@implementation APBadgeLabel
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
}
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rc = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    rc.origin.y -= 2;
    return rc;
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
    
    [self registerForBroadcast:kNotifyMessageFromRemotePush
                         block:^(APMainViewController * me, NSDictionary * aps) {
                             me->_offersBadge.text = [NSString stringWithFormat:@"%d", [aps[@"aps"][@"badge"] integerValue]];
                             me->_offersBadge.hidden = NO;
                         }];
    [self registerForBroadcast:kNotifyRemotePushPickedUp
                         block:^(APMainViewController * me, id blahFoo) {
                             me->_offersBadge.hidden = YES;
                         }];
}

@end


//
//  APPINButton.m
//  ArgoPay
//
//  Created by victor on 11/1/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APPINButton.h"

@implementation APPINButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self ) {
        [self setupLayer];
    }
    return self;
}

-(void)setupLayer
{
    CALayer * layer = self.layer;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 2.0;
    layer.cornerRadius = 10.0;
    layer.masksToBounds = YES;
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor argoOrange];
    self.showsTouchWhenHighlighted = YES;
    [self.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:30.0]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

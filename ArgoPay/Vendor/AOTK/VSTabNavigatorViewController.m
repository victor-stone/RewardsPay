//
//  VSTabNavigatorViewController.m
//  ArgoPay
//
//  Created by victor on 10/14/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "VSTabNavigatorViewController.h"

@implementation VSTabNavigatorViewController {
    CGFloat _originalEmbedHeight;

}

-(void)awakeFromNib
{
    Class tabClass = [VSTabNavigator class];
    Class embedClass = [VSTabNavigatorEmbed class];
    for( UIView * view in self.view.subviews )
    {
        if( [view isKindOfClass:tabClass] )
        {
            _tabNavigator = (VSTabNavigator *)view;
            _tabNavigator.delegate = self;
        }
        else if( [view isKindOfClass:embedClass] )
        {
            _navigationEmbedding = (VSTabNavigatorEmbed *)view;
        }
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if( !_originalEmbedHeight )
    {
        _originalEmbedHeight = _navigationEmbedding.frame.size.height;
    }
}

-(VSNavigationViewController *)vsTabNavigatorGetNavigationController
{
    return _navigationViewController;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue on tab navigator: %@ ", segue.identifier);
    if( _navigationEmbedding )
    {
        UIViewController * vc = segue.destinationViewController;
        CGRect rc = _navigationEmbedding.frame;
        rc.size.height = vc.underTabBar == YES ? _originalEmbedHeight + _tabNavigator.frame.size.height : _originalEmbedHeight;
        _navigationEmbedding.frame = rc;
    }
    if( [segue.identifier isEqualToString:kNavigatorEmbedSegue] )
        _navigationViewController = segue.destinationViewController;
    else
        [_tabNavigator prepareForSegue:segue];
}

@end

@implementation VSTabNavigatorEmbed
@end

@implementation UIViewController (VSTabNavigator)

-(BOOL)underTabBar
{
    return NO;
}

@end
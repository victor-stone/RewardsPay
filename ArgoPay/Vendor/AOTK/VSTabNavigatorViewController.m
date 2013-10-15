//
//  VSTabNavigatorViewController.m
//  ArgoPay
//
//  Created by victor on 10/14/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "VSTabNavigatorViewController.h"

@implementation VSTabNavigatorViewController

-(void)awakeFromNib
{
    Class tabClass = [VSTabNavigator class];
    for( UIView * view in self.view.subviews )
    {
        if( [view isKindOfClass:tabClass] )
        {
            _tabNavigator = (VSTabNavigator *)view;
            _tabNavigator.delegate = self;
            break;
        }
    }
}

-(VSNavigationViewController *)vsTabNavigatorGetNavigationController
{
    return _navigationViewController;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kNavigatorEmbedSegue] )
        _navigationViewController = segue.destinationViewController;
    else
        [_tabNavigator prepareForSegue:segue];
}

@end

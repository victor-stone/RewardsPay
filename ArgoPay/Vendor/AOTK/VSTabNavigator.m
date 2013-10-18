//
//  VSTabNavigator.m
//  VSNavigation
//
//  Created by victor on 08/01/13
//  Copyright (c) 2013 AOTK. All rights reserved.
//

#import "VSTabNavigator.h"

/*
    Order of events:
        1) User taps button
        2) Triggers segue - we get prepareForSegue:
        3) Segue:perform is run
        4) Our tabPress gets called
 */
@implementation VSTabNavigator {
    __weak VSNavigationViewController*  _navigationController;
    UIButton * _closeButton;
    NSString * _lastSegueName;
    NSMutableDictionary * _actionSwap;
}

-(void)awakeFromNib
{
    _selectedIndex = -1;
    [super awakeFromNib];
    Class buttonClass = [UIButton class];
    _actionSwap = [NSMutableDictionary new];
    NSUInteger nextTag = 1;
    for( UIView * view in self.subviews )
    {
        if( [view isKindOfClass:buttonClass] )
        {
            UIButton * button = (UIButton *)view;
            id target = nil;
            for( target in button.allTargets ) { break; }
            if( target )
            {
                NSString * action = nil;
                for( action in [button actionsForTarget:target forControlEvent:UIControlEventTouchUpInside]) { break; }
                button.tag = nextTag++;
                _actionSwap[@(button.tag)] = @[ target, action ];
                [button addTarget:self action:@selector(tabPress:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}


-(VSNavigationViewController *)navController
{
    if( !_navigationController )
        _navigationController = [_delegate vsTabNavigatorGetNavigationController];
    return _navigationController;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue
{
    // You are here because a button that is wired to a segue
    // has been tapped. There are only two cases when that can
    // happen:
    // 1. No modal tabs are open in which case _selected tab is
    //    nil and we just run the segue normal (i.e. slide up
    //    the new controller)
    //  2. A modal tab for another controller is up in which case
    //     _selectedTab is NOT nil and we need to enable 'swap'
    //     mode in the segue.
    //
    //  There can never be a case where a destination controller
    //  is already showing because when that controller showed
    //  we disabled its button's ability to trigger another.
    //  See -selectButton:
    //
    if( [segue isKindOfClass:[VSTabModalSegue class]] )
    {
        VSTabModalSegue * seg = (VSTabModalSegue *)segue;
        seg.doSwap = _selectedTab != nil;
    }
    UIViewController * dest = segue.destinationViewController;
    VSNavActionBlock block = ^(id ctx, id sender) {
        [self deSelectButton];
    };
    [dest.backButtonHooks addObject:block];
}

-(void)selectButton:(UIButton *)button
{
    button.selected = YES;
    NSArray *actionSwap = _actionSwap[@(button.tag)];
    [button removeTarget:actionSwap[0] action:NSSelectorFromString(actionSwap[1]) forControlEvents:UIControlEventTouchUpInside];
    _selectedTab = button;
}

-(void)deSelectButton
{
    _selectedTab.selected = NO;
    NSArray *actionSwap = _actionSwap[@(_selectedTab.tag)];
    id target = actionSwap[0];
    SEL sel = NSSelectorFromString(actionSwap[1]);
    [_selectedTab removeTarget:self action:@selector(tabPress:) forControlEvents:UIControlEventTouchUpInside];
    [_selectedTab addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [_selectedTab addTarget:self action:@selector(tabPress:) forControlEvents:UIControlEventTouchUpInside];
    _selectedTab = nil;
}

-(IBAction)tabPress:(UIButton *)button
{
    // case 1: nothing was selected
    if( !_selectedTab )
    {
        // The slide up segue has already run, highlight the button
        [self selectButton:button];
    }
    else
    {
        // case 2: something was selected, we're de-selecting it
        if( _selectedTab == button )
        {
            // If you are here, no segue has run
            // so trigger a 'back' action
            // which will call deSelectButton
            [[self navController] performBack];
        }
        // case 3: something was selected, we're selecting something else
        else
        {
            // The swap segue has already run
            [self deSelectButton];
            [self selectButton:button];
        }
    }
}

@end

@implementation VSTabModalSegue

-(id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier source:source destination:destination];
}
-(void)perform
{
    if( _doSwap )
    {
        VSNavigationViewController * nav = self.navigationController;
        [nav swapTopViewController:self.destinationViewController transition:kVSTransitionSlideUpSwap];
    }
    else
    {
        [super perform];
    }
}

-(VSNavigationViewController *)navigationController
{
    VSNavigationViewController *nav = nil;
    SEL sel = @selector(vsTabNavigatorGetNavigationController);
    
    if( [self.sourceViewController respondsToSelector:sel] )
        nav = [self.sourceViewController vsTabNavigatorGetNavigationController];
    else if( [self.destinationViewController respondsToSelector:sel] )
        nav = [self.destinationViewController vsTabNavigatorGetNavigationController];
    
    return nav;
}


@end

@interface VSNoAnimationPushSegue : VSTabModalSegue

@end
@implementation VSNoAnimationPushSegue
-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination
{
    return [self initWithIdentifier:identifier
                             source:source
                        destination:destination
                             unwind:NO
                         transition:kVSTransitionNoAnimation];
}
@end


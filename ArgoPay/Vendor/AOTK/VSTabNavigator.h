//
//  VSTabNavigator.h
//  VSNavigation
//
//  Created by victor on 08/01/13
//  Copyright (c) 2013 AOTK. All rights reserved.
//


#import "VSNavigationViewController.h"

@class VSTabNavigator;

@protocol VSTabNavigatorDelegate <NSObject>
@required
-(VSNavigationViewController *)vsTabNavigatorGetNavigationController;
@end

@interface VSTabNavigator : UIView

@property (nonatomic,weak) IBOutlet id<VSTabNavigatorDelegate> delegate;

@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray * tabs;

@property (nonatomic,strong) UIButton * selectedTab;
@property (nonatomic) NSUInteger selectedIndex;

-(IBAction)tabPress:(UIButton *)sender;
-(void)prepareForSegue:(UIStoryboardSegue *)segue;
@end

@interface VSTabModalSegue : VSSlideUpSegue
@property (nonatomic) BOOL doSwap;
@end



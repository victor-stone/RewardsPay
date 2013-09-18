//
//  VSSettings.m
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import "VSSettings.h"
#import "IASKSwitch.h"
#import "IASKSettingsReader.h"

@interface IASKAppSettingsViewController (dummy)
- (void)toggledValue:(id)sender;
@end


@implementation VSSettingsExtensions

- (void)toggledValue:(id)sender
{
    [super toggledValue:sender];
    IASKSwitch *toggle    = (IASKSwitch*)sender;
    IASKSpecifier *spec   = [_settingsReader specifierForKey:[toggle key]];
    
    if ([self.delegate respondsToSelector:@selector(settingsViewController:buttonTappedForSpecifier:)]) {
        [self.delegate settingsViewController:self buttonTappedForSpecifier:spec];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerText = nil;
    
    if( [self.delegate respondsToSelector:@selector(settingsViewController:tableView:titleForFooterForSection:)] )
    {
        footerText = [self.delegate settingsViewController:self tableView:self.tableView titleForFooterForSection:section];
        if( footerText.length )
            return footerText;
    }
    return [super tableView:tableView titleForFooterInSection:section];
}
@end


@implementation VSSettingsCommonDelegate

-(id)initWithParent:(UIViewController *)parent
           settings:(IASKAppSettingsViewController *)settings
{
    self = [super init];
    if( self )
    {
        settings.delegate = self;
        self.parentVC = parent;
    }
    return self;
}

-(void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender
{
    [_parentVC.navigationController popViewControllerAnimated:YES];
}

@end

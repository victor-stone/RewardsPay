//
//  VSSettings.h
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASKAppSettingsViewController.h"

@protocol VSSettingDelegateExtensions<IASKSettingsDelegate>
@optional

- (NSString *) settingsViewController:(IASKAppSettingsViewController*)settingsViewController
                            tableView:(UITableView *)tableView
             titleForFooterForSection:(NSInteger)section;
@end

@interface VSSettingsExtensions : IASKAppSettingsViewController

@end


@interface VSSettingsCommonDelegate : NSObject<VSSettingDelegateExtensions>
@property (nonatomic,weak) UIViewController * parentVC;
@end

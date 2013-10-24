//
//  APSettingsViewController.m
//  ArgoPay
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#import "VSSettings.h"
#import "APStrings.h"
#import "VSNavigationViewController.h"

@interface APSettingNavigationController : UINavigationController
@end
@implementation APSettingNavigationController

-(BOOL)navigationBarHidden
{
    return YES;
}
@end

@interface APSettingsViewController : VSSettingsExtensions

@end

@implementation APSettingsViewController {
}

APLOGRELEASE

- (IBAction)done:(id)sender
{
    [[self vsNavigationController] performBack];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( self.navigationController.topViewController == self )
    {
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done:)];
        self.navigationItem.leftBarButtonItem  = bbi;

#ifndef ALLOW_DEBUG_SETTINGS
        [self setHiddenKeys:[NSSet setWithArray:@[kSettingDebug]] animated:NO];
#endif
    }
    /*
    [self registerForBroadcast:kNotifyUserSettingChanged block:^(APSettingsViewController *me, NSDictionary *info)
    {
        NSLog(@"Setting changed: %@", info);
    }];
     */
}

@end

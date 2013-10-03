//
//  APSettingsViewController.m
//  ArgoPay
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#import "VSSettings.h"
#import "APStrings.h"

@interface APSettingsViewController : VSSettingsExtensions

@end

@implementation APSettingsViewController
- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

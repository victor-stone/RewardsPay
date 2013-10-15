//
//  APHomeViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APScanView.h"
#import "APStrings.h"
#import "APPopup.h"
#import "VSTabNavigatorViewController.h"

#define kTransitionDuration 0.5

#pragma mark - Local Interfaces

@interface APMainViewController : VSTabNavigatorViewController<APScanDelegate>
@property (weak, nonatomic) IBOutlet UIView *orangeBox;
@end

@implementation APMainViewController {

    APScanRequestWatcher * _scanWatcher;
    UIViewController * _scanner;
    BOOL _scanTransition;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _scanWatcher = [[APScanRequestWatcher alloc] initWithDelegate:self];

    CALayer *layer = _orangeBox.layer;
    layer.cornerRadius = 5.0;
    layer.masksToBounds = YES;
}

-(UIViewController *)scanHostViewController
{
    return self;
}

-(void)toggleScanner:(APScannerDoneBlock)block
{
    /*
    BOOL scannerOpen = NO;
    BOOL inTransition = NO;
    
    @synchronized(self) {
        scannerOpen = _scanner != nil;
        inTransition = _scanTransition;
    }
    
    if( inTransition )
    {
        APLOG(kDebugScan, @"Scan transition is under way, tap ignored", 0);
        return;
    }
    
    APLOG(kDebugScan, @"Scan tansition on",0);
    
    _scanTransition = YES;
    
    if( scannerOpen )
    {
        [_tabNavigator highlightTab:_lastNavTab];
        CGRect rc = self.view.frame;
        rc.origin.y = rc.size.height;
        CGFloat duration = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingSlidingCameraView] ? 0.5 : 0.0;
        [UIView animateWithDuration:duration animations:^{
            _scanner.view.frame = rc;
        } completion:^(BOOL finished) {
            [_scanner.view removeFromSuperview];
            [_scanner willMoveToParentViewController:nil];
            [_scanner removeFromParentViewController];
            _scanner = nil;
            if( block )
                block(self);
            _scanTransition = NO;
            APLOG(kDebugScan, @"Scan tansition OFF (1)",0);
        }];
    }
    else
    {
        _scanner = [_scanWatcher request];
        [_scanner willMoveToParentViewController:self];
        [self addChildViewController:_scanner];
        UIView * scannerView = _scanner.view;
        CGRect rc = self.view.frame;
        CGRect targetRC = rc;
        targetRC.origin.y = 0;
        rc.origin.y = rc.size.height;
        scannerView.frame = rc;
        APLOG(kDebugScan, @"Inserting scanner view into home screen", 0);
        [self.view insertSubview:scannerView belowSubview:_tabNavigator];
        CGFloat duration = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingSlidingCameraView] ? 0.5 : 0.0;
        [UIView animateWithDuration:duration animations:^
        {
            [_tabNavigator highlightTab:_tabNavigator.scan.vcNav];
            scannerView.frame = targetRC;
        } completion:^(BOOL finished) {
            _scanTransition = NO;
            APLOG(kDebugScan, @"Scan tansition OFF (2)",0);
        }];
    }
     */
}

@end

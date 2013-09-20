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
#import "APTransaction.h"
#import "APTranasctionViewController.h"

#pragma mark - Local Interfaces

@class APTabNavigator;

@interface APMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet APTabNavigator *tabNavigator;
@property (weak, nonatomic) IBOutlet UIView *blackTapNavBackground;
@property (weak, nonatomic) IBOutlet UIView *embeddingContainer;

-(void)navigateTo:(NSString *)vcName;
@end

@interface APTab : UIView
@property (weak,nonatomic) IBOutlet UIImageView * image;
@property (weak,nonatomic) IBOutlet UILabel *label;
@property (nonatomic,strong) NSString *vcNav;
@end

@interface APTabNavigator : UIView
@property (weak,nonatomic) IBOutlet APTab *offers;
@property (weak,nonatomic) IBOutlet APTab *scan;
@property (weak,nonatomic) IBOutlet APTab *location;

@property (weak,nonatomic) APTab *currentTab;
@end

#pragma mark - Local Implementations

@implementation APTab

-(void)wireUp:(APMainViewController *)homeController
{
    UITapGestureRecognizer * tgr = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender,
                                                                                   UIGestureRecognizerState state,
                                                                                   CGPoint location)
                                                                        {
                                                                            [homeController navigateTo:self.vcNav];
                                                                        }];
    [self addGestureRecognizer:tgr];
}
@end


@implementation APTabNavigator

-(void)wireUp:(APMainViewController *)homeController
{
    [_offers wireUp:homeController];
    [_scan wireUp:homeController];
    [_location wireUp:homeController];
}

@end

#pragma mark - Main View Controller

typedef void (^APScannerDoneBlock)(APMainViewController *);


@implementation APMainViewController {
    __weak APTab *_currentTab;
    
    NSString * _lastNavTab;
    UIViewController * _currentEmbeddedVC;
    
    APScanRequestWatcher * _scanWatcher;
    UIViewController * _scanner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[_tabNavigator wireUp:self];
    _lastNavTab = _tabNavigator.offers.vcNav;
    [self registerForEvents];    
}

-(void)registerForEvents
{
    [self registerForBroadcast:kNotifyScanComplete
                         block:^(APMainViewController *me, APScanResult *result)
    {
        [me toggleScanner:^(APMainViewController *me) {
            if( result == AP_EMPTY_SCAN_RESULT )
            {
                [APPopup msgWithParent:me.view text:@"QR Code scan was cancelled"];
            }
            else
            {
                APTranasctionViewController * vc = [me.storyboard instantiateViewControllerWithIdentifier:kViewTransaction];
                vc.scanResult = result;
                [NSObject performBlock:^{
                    [me presentViewController:vc animated:YES completion:nil];
                } afterDelay:0.3];
            }
        }];
    }];

    [self registerForBroadcast:kNotifyTransactionComplete
                         block:^(APMainViewController *me,
                                 APTransactionRequest *request)
    {
        NSString * msg = nil;
        if( request.state == kTransactionStateCancelled )
            msg = @"Transaction Canelled";
        else if( request.state == kTransactionStateAccepted )
            msg = @"Transaction Accepted! Thanks for using ArgoPay!";
        [APPopup msgWithParent:me.view text:msg];
    }];
    
}
-(void)toggleScanner:(APScannerDoneBlock)block
{
    if( _scanner )
    {
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
            _scanWatcher = nil;
            if( block )
                block(self);
        }];
    }
    else
    {
        _scanWatcher = [APScanRequestWatcher new];
        _scanner = [_scanWatcher request:self];
        [_scanner willMoveToParentViewController:self];
        [self addChildViewController:_scanner];
        UIView * scannerView = _scanner.view;
        CGRect rc = self.view.frame;
        CGRect targetRC = rc;
        targetRC.origin.y = 0;
        rc.origin.y = rc.size.height;
        scannerView.frame = rc;
        [self.view insertSubview:scannerView belowSubview:_tabNavigator];
        CGFloat duration = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingSlidingCameraView] ? 0.5 : 0.0;
        [UIView animateWithDuration:duration animations:^{
            scannerView.frame = targetRC;
        }];
    }
}

-(void)slideInView:(NSString *)vcName
{
    UIViewController * dest = [self.storyboard instantiateViewControllerWithIdentifier:vcName];
    UIViewController * src = self;
    CGRect rc = _embeddingContainer.bounds;
    
    [_currentEmbeddedVC willMoveToParentViewController:nil];
    [_currentEmbeddedVC removeFromParentViewController];
    
    [dest willMoveToParentViewController:src];
    [src addChildViewController:dest];
    UIView * newView = dest.view;

//   rc.size.height -= 44;
    CGRect targetRC = rc;
    rc.origin.x = rc.size.width;
    newView.frame = rc;
    [_embeddingContainer addSubview:newView];
    
    [dest didMoveToParentViewController:src];
    [UIView animateWithDuration:0.5 animations:^{
        dest.view.frame = targetRC;
    }];
    
    _currentEmbeddedVC = dest;
    
    _lastNavTab = vcName;
    
#ifdef DEBUG
    if( APENABLED(kDebugViews) )
    {
        APDebug(kDebugFire, @"Children -------------");
        
        for( UIViewController * vc in self.childViewControllers )
        {
            APDebug(kDebugFire, @"Child vc: %@", vc);
            for( UIViewController * gvc in vc.childViewControllers )
            {
                APDebug(kDebugFire, @"GrandChild vc: %@", gvc);
            }
        }
    }
#endif
}

-(void)navigateTo:(NSString *)vcName
{
    if( [vcName isEqualToString:kViewScanner] )
    {
        [self toggleScanner:nil];
    }
    else
    {
        if( _scanner )
            [self toggleScanner:nil];
        
        if( _lastNavTab == vcName )
            return;
        
        if( [vcName isEqualToString:kViewTransaction] )
        {
            UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:vcName];
            [self presentViewController:vc animated:YES completion:nil];
        }
        else
        {
            [self slideInView:vcName];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueMainEmbedding] )
    {
        _currentEmbeddedVC = segue.destinationViewController;
    }
}

@end

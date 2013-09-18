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

#import "APTranasctionViewController.h"

#pragma mark - Local Interfaces

@class APTabNavigator;

@interface APMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet APTabNavigator *tabNavigator;
@property (weak, nonatomic) IBOutlet UIView *blackTapNavBackground;

-(void)navigateTo:(NSString *)vcName;
@property (weak, nonatomic) IBOutlet UIView *messagePopup;
@property (weak, nonatomic) IBOutlet UILabel *messageTitle;
@property (weak, nonatomic) IBOutlet UILabel *messageText;

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

@implementation APMainViewController {
    __weak APTab *_currentTab;
    NSString * _lastNavTab;
    APScanRequestWatcher * _scanWatcher;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[_tabNavigator wireUp:self];
    _lastNavTab = _tabNavigator.offers.vcNav;
    _messagePopup.alpha = 0.0;
    [self registerForEvents];
    _scanWatcher = [APScanRequestWatcher new];
    
}

-(void)registerForEvents
{
    [self registerForBroadcast:kNotifyScanComplete block:^(APMainViewController *me, APScanResult *result) {

        if( result == AP_EMPTY_SCAN_RESULT )
        {
            [APPopup msgWithParent:self.view text:@"QR Code scan was cancelled"];
        }
        else
        {
            APTranasctionViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewTransaction];
            vc.scanResult = result;
            [NSObject performBlock:^{
                [self presentViewController:vc animated:YES completion:nil];
            } afterDelay:0.3];
        }
    }];
    
    [self registerForBroadcast:kNotifyPaymentSucceeded block:^(APMainViewController *me, id payload) {
        [UIView animateWithDuration:0.4 animations:^{
            _messagePopup.alpha = 1.0;
        }];
    }];
    
}
-(void)toggleScanner
{
    [self broadcast:kNotifyRequestScanner payload:self];
}

-(void)slideInView:(NSString *)vcName
{
    UIViewController * dest = [self.storyboard instantiateViewControllerWithIdentifier:vcName];
    UIViewController * src = self.childViewControllers[0];
    CGRect rc = src.view.bounds;
    [dest willMoveToParentViewController:nil];
    [dest removeFromParentViewController];
    [src addChildViewController:dest];
    [src.view addSubview:dest.view];
    rc.size.height -= 44;
    CGRect targetRC = rc;
    rc.origin.x = rc.size.width;
    dest.view.frame = rc;
    [dest didMoveToParentViewController:src];
    [UIView animateWithDuration:0.5 animations:^{
        dest.view.frame = targetRC;
    }];
    
    _lastNavTab = vcName;
}

-(void)navigateTo:(NSString *)vcName
{
    if( [vcName isEqualToString:kViewScanner] )
    {
        [self toggleScanner];
    }
    else
    {
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
}

@end

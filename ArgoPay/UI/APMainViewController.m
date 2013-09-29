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
#import "APRemoteStrings.h"

#define kTransitionDuration 0.5

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // first time through
    // see APAppDelegate
    
    if( self.view.alpha == 0.0 )
    {
        [UIView animateWithDuration:1.8 animations:^{
            self.view.alpha = 1.0;
        }];
    }
}

-(void)registerForEvents
{
    [self registerForBroadcast:kNotifyScanComplete
                         block:^(APMainViewController *me, APScanResult *result)
    {
        [me toggleScanner:^(APMainViewController *me) {
            if( result == AP_EMPTY_SCAN_RESULT )
            {
                [APPopup msgWithParent:me.view text:NSLocalizedString(@"QR Code scan was cancelled", "popup")];
            }
            else
            {
                [NSObject performBlock:^{
                    [me attemptTransaction:result];
                } afterDelay:0.3];
            }
        }];
    }];
    
    [self registerForBroadcast:kNotifyTransactionUserActed
                         block:^(APMainViewController *me, APTransactionApprovalRequest *request)
     {
         [request performRequest:^(APRemoteRepsonse *response, NSError *err)
         {
             if( err )
             {
                 [me showError:err];
             }
             else
             {
                 [APPopup msgWithParent:me.view text:response.UserMessage];
             }
         }];
     }];
}

-(void)handleTransaction:(APPopup *)popup transID:(NSString *)transID
{
    APRemoteAPIRequestBlock handleStatusReponse = ^(APTransactionStatusResponse *response, NSError *err)
    {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            NSString *stat = response.TransStatus;
            
            if( [stat isEqualToString:kRemoteValueTransactionStatusPending] )
            {
                [NSObject performBlock:^{
                    [self handleTransaction:popup transID:transID];
                } afterDelay:0.5];
                return;
            }
            
            [popup dismiss];
            
            if( [stat isEqualToString:kRemoteValueTransactionStatusInsufficientFunds] )
            {
                [APPopup msgWithParent:self.view text:NSLocalizedString(@"Sorry, there are insufficient funds in your ArgoPay Account to cover this purchase!", @"TransactionResponse")];
            }
            else if( [stat isEqualToString:kRemoteValueTransactionStatusServerCancelled] )
            {
                [APPopup msgWithParent:self.view text:NSLocalizedString(@"This transaction was cancelled!", @"TransactionResponse")];
            }
            else if( [stat isEqualToString:kRemoteValueTransactionStatusTimeOut] )
            {
                [APPopup msgWithParent:self.view text:NSLocalizedString(@"This transaction was cancelled because it was taking too long.", @"TransactionResponse")];
            }
            else if( [stat isEqualToString:kRemoteValueTransactionStatusReadyForApproval] )
            {
                APTranasctionViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewTransaction];
                vc.transID = transID;
                vc.statusResponse = response;
                [NSObject performBlock:^{
                    [self presentViewController:vc animated:YES completion:nil];
                } afterDelay:0.3];
            }
        }
    };
    
    APTransactionStatusRequest *request = [APTransactionStatusRequest new];
    request.TransID = transID;
    [request performRequest:handleStatusReponse];
}

-(void)attemptTransaction:(APScanResult *)result
{
    __block APPopup *popup = [APPopup withNetActivity:self.view];
    
    // yea, all this should be somewhere else
    
    APTransactionStartRequest *start = [APTransactionStartRequest new];
    start.AToken = @"justAToken";
    start.QrData = result.text;
    start.Lat = @(83223.02323);
    start.Long = @(-99933.000342322);
    [start performRequest:^(APTransactionIDResponse *idResponse, NSError *err) {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            [NSObject performBlock:^{
                [self handleTransaction:popup transID:idResponse.TransID];
            } afterDelay:0.1];
        }
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
    [_currentEmbeddedVC willMoveToParentViewController:nil];
    [_currentEmbeddedVC removeFromParentViewController];

    [dest willMoveToParentViewController:src];
    [src addChildViewController:dest];
    UIView * newView = dest.view;
    UIView * oldView = [_embeddingContainer subviews][0];
    CGRect rc = _embeddingContainer.bounds;
    newView.frame = rc;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:_embeddingContainer
                             cache:YES];
    [oldView removeFromSuperview];
    [_embeddingContainer addSubview:newView];
	[UIView commitAnimations];
    
    [dest didMoveToParentViewController:src];
    _currentEmbeddedVC = dest;
    
    _lastNavTab = vcName;
    
#ifdef DEBUG
    if( APENABLED(kDebugViews) )
    {
        APDebug(kDebugFire, @"Children VC -------------");
        
        for( UIViewController * vc in self.childViewControllers )
        {
            APDebug(kDebugFire, @"Child vc: %@", vc);
            for( UIViewController * gvc in vc.childViewControllers )
            {
                APDebug(kDebugFire, @"GrandChild vc: %@", gvc);
            }
        }
        for( UIView * view in _embeddingContainer.subviews )
        {
            APDebug(kDebugFire, @"Embedding child: %@", view);
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
        
        [self slideInView:vcName];
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

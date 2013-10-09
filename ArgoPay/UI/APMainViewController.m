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

#define kTransitionDuration 0.5

#pragma mark - Local Interfaces

@class APTabNavigator;

@interface APMainViewController : UIViewController<APScanDelegate>

@property (weak, nonatomic) IBOutlet APTabNavigator *tabNavigator;
@property (weak, nonatomic) IBOutlet UIView *blackTapNavBackground;
@property (weak, nonatomic) IBOutlet UIView *embeddingContainer;

-(void)navigateTo:(NSString *)vcName;
@end

@interface APTab : UIView
@property (weak,nonatomic) IBOutlet UIImageView * image;
@property (weak,nonatomic) IBOutlet UILabel *label;
@property (nonatomic,strong) NSString *vcNav;
@property (nonatomic) BOOL highlighted;
@end

@interface APScanTab : APTab
@end

@interface APTabNavigator : UIView
@property (weak,nonatomic) IBOutlet APTab *offers;
@property (weak,nonatomic) IBOutlet APTab *scan;
@property (weak,nonatomic) IBOutlet APTab *location;

@property (weak,nonatomic) APTab *currentTab;

-(NSString *)titleForVCName:(NSString *)vcName;
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

-(void)setHighlighted:(BOOL)highlighted
{
    _image.highlighted = highlighted;
    _label.highlighted = highlighted;
    _highlighted = highlighted;
}

@end

@implementation APScanTab {
    UIColor * _defaultColor;
}

-(void)setHighlighted:(BOOL)highlighted
{
    if( !_defaultColor )
        _defaultColor = self.backgroundColor;
    
    BOOL oldValue = self.highlighted;
    if( oldValue != highlighted )
    {
        [super setHighlighted:highlighted];
        self.hidden = YES;
        if( highlighted )
        {
            self.backgroundColor = [UIColor whiteColor];
            self.label.text = NSLocalizedString(@"Cancel", @"scan tab");
            self.label.textColor = [UIColor orangeColor];
        }
        else
        {
            self.backgroundColor = _defaultColor;
            self.label.text = NSLocalizedString(@"Scan", @"scan tab");
            self.label.textColor = [UIColor whiteColor];
        }
        self.hidden = NO;
    }
}

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)theKey {
    
    CATransition *theAnimation = nil;

    NSString * matches = @"hidden"; // kCAOnOrderIn
    if ( [theKey isEqualToString:matches] ) {
        
        theAnimation = [[CATransition alloc] init];
        theAnimation.duration = 0.5;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        if( self.highlighted )
        {
            theAnimation.type = kCATransitionMoveIn;
            theAnimation.subtype = kCATransitionFromTop;
        }
        else
        {
            theAnimation.type = kCATransitionReveal;
            theAnimation.subtype = kCATransitionFromBottom;
            
        }
    }
    return theAnimation;
}


@end

@implementation APTabNavigator

-(void)wireUp:(APMainViewController *)homeController
{
    [_offers wireUp:homeController];
    [_scan wireUp:homeController];
    [_location wireUp:homeController];
}

-(NSString *)titleForVCName:(NSString *)vcName
{
    if( _offers.vcNav == vcName )
        return _offers.label.text;
    if( _scan.vcNav == vcName )
        return nil;
    return _location.label.text;
}

-(void)highlightTab:(NSString *)vcName
{
    [UIView animateWithDuration:0.4 animations:^{
        _offers.highlighted = _offers.vcNav == vcName;
        _location.highlighted = _location.vcNav == vcName;
        _scan.highlighted = _scan.vcNav == vcName;
    }];
}
@end

#pragma mark - Main View Controller

@implementation APMainViewController {
    __weak APTab *_currentTab;
    
    NSString * _lastNavTab;
    UIViewController * _currentEmbeddedVC;
    
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
    [self argoPayIze];
	[_tabNavigator wireUp:self];
    _lastNavTab = _tabNavigator.offers.vcNav;
    self.title = _tabNavigator.offers.label.text;
    _tabNavigator.offers.highlighted = YES;
    _scanWatcher = [[APScanRequestWatcher alloc] initWithDelegate:self];
    [self registerForEvents];
    
    CALayer *layer = _tabNavigator.scan.layer;
    layer.cornerRadius = 5.0;
    layer.masksToBounds = YES;

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
}

-(UIViewController *)scanHostViewController
{
    return self;
}

-(void)toggleScanner:(APScannerDoneBlock)block
{
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
    self.title = dest.title; // see: UIViewControler:addBackButton
    [_tabNavigator highlightTab:vcName];
    
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

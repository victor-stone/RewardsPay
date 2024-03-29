//
//  VSViewController.m
//  VSNavigation
//
//  Created by victor on 08/01/13
//  Copyright (c) 2013 AOTK. All rights reserved.
//

#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlocksKit.h"

#define VS_VIEWCONTROLLER_DECLS

#define VSNAV_STRING(name) NSString * const name = @#name;

#import "VSNavigationViewController.h"

#pragma mark -
#pragma mark Custom segues

@interface VSRootViewControllerSegue : UIStoryboardSegue
@end

@interface VSDismissAndUnwindSegue : VSNavigationSegue
@end

@interface VSNavigationViewController () <UINavigationBarDelegate>
@end


typedef void (^Lamda)();
typedef void (^BoolLamda)(BOOL);

@interface VSNavWorker : NSObject
@property (nonatomic,strong) NSArray *viewControllersToRemove;
@property (nonatomic,strong) NSArray *viewControllersToAdd;
@property (nonatomic,strong) Lamda finishRemovingViewControllers;
@property (nonatomic,strong) Lamda finishAddingViewControllers;
@property (nonatomic,strong) UIViewController *oldTopViewController;
@property (nonatomic,strong) UIViewController *nuwTopViewController;
@end

@implementation VSNavWorker
@end

#pragma mark -
#pragma mark Navigator

@implementation VSNavigationViewController {
    UIColor * _navTextColor;
    BOOL _navBarHidden;
    UINavigationBar *_navigationBar;
    NSArray *_viewControllers;
}

typedef enum _VSTransitionTypeID {
    kVSTransitionNoAnimationID,
    kVSTransitionFromRightID,
    kVSTransitionFromLeftID,
    kVSTransitionSlideUpID,
    kVSTransitionRevealDownID,
    kVSTransitionSlideUpSwapID
} VSTransitionTypeID;


+(VSTransitionTypeID)transitionNameToID:(VSTransitionType)name
{
    static NSDictionary * map = nil;
    if( !map )
    {
#define TNAMEID(name) name: @(name##ID)
        
        map = @{ TNAMEID(kVSTransitionNoAnimation),
                 TNAMEID(kVSTransitionFromRight),
                 TNAMEID(kVSTransitionFromLeft),
                 TNAMEID(kVSTransitionSlideUp),
                 TNAMEID(kVSTransitionRevealDown),
                 TNAMEID(kVSTransitionSlideUpSwap)
                 };
    }
    
    return (VSTransitionTypeID)[map[name] unsignedIntegerValue];
}

//| ----------------------------------------------------------------------------
//  We provide our own view.
//
- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    _navigationBar = [[UINavigationBar alloc] init];
    _navigationBar.translucent = NO;
    _navigationBar.delegate = self;
    _navigationBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:_navigationBar];
}


//| ----------------------------------------------------------------------------
- (void)viewDidLoad
{
    // This segue creates our initial root view controller.  Users of this
    // class are expected to define a segue named 'RootViewController' with
    // segue type VSRootViewControllerSegue.  The destination
    // of this segue should be the scene of the desired initial root view
    // controller.
    [self performSegueWithIdentifier:kSegueRootViewController sender:self];
}

-(UINavigationBar *)navigationBar
{
    return _navigationBar;
}

//| ----------------------------------------------------------------------------
//! Returns the appropriate frame for displaying a child view controller.
//
- (CGRect)frameForTopViewController
{
    if( _navBarHidden == YES )
    {
        CGFloat topLayoutGuide = 0.0f;
        if ([self respondsToSelector:@selector(topLayoutGuide)])
            topLayoutGuide = [self.topLayoutGuide length];
        return CGRectMake(0, topLayoutGuide, self.view.bounds.size.width, self.view.bounds.size.height);
    }

    return CGRectMake(0,
                      _navigationBar.frame.size.height + _navigationBar.frame.origin.y,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - _navigationBar.frame.size.height - _navigationBar.frame.origin.y);

}


//| ----------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
{
    if( _navBarHidden != YES )
    {
        [_navigationBar sizeToFit];
        
        // Offset the navigation bar to account for the status bar.
        CGFloat topLayoutGuide = 0.0f;
        if ([self respondsToSelector:@selector(topLayoutGuide)])
            topLayoutGuide = [self.topLayoutGuide length];
        
        _navigationBar.frame = CGRectMake(_navigationBar.frame.origin.x, topLayoutGuide,
                                          _navigationBar.frame.size.width, _navigationBar.frame.size.height);
        
    }
    self.topViewController.view.frame = [self frameForTopViewController];
}

#pragma mark Unwind segue support

//| ----------------------------------------------------------------------------
//! Returns the view controller managed by the receiver that wants to handle
//! the specified unwind action.
//
//  This method is called when any unwind segue is triggered.
//  It is the responsibility of the *parent* of the
//  view controller that triggered the unwind segue to locate a
//  view controller that responds to the unwind action for the triggered segue.
//
- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    NAVDEBUG(@"Looking for view controller for %@ from %@", NSStringFromSelector(action),fromViewController);
    
    // Like UINavigationController, search the array of view controllers
    // managed by this container in reverse order.
    for (UIViewController *vc in [_viewControllers reverseObjectEnumerator])
        // Always use -canPerformUnwindSegueAction:fromViewController:withSender:
        // to determine if a view controller wants to handle an unwind action.
        if ([vc canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender])
            return vc;
    
    // Always invoke the super's implementation if no view controller managed
    // by this container wanted to handle the unwind action.
    return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}


//| ----------------------------------------------------------------------------
//! Returns a segue object for transitioning to toViewController.
//
//  This method is called if the destination of an unwind segue is a child
//  view controller of this container.  This method returns an instance
//  of segue that transitions to the destination
//  view controller of the unwind segue (toViewController).
//
- (UIStoryboardSegue*)segueForUnwindingToViewController:(UIViewController *)toViewController
                                     fromViewController:(UIViewController *)fromViewController
                                             identifier:(NSString *)identifier
{
    NAVDEBUG(@"Looking for unwind segue called: %@", identifier);
    
    if( [identifier isEqualToString:kSegueErrorUnwind] )
    {
        return [[VSDismissAndUnwindSegue alloc] initWithIdentifier:identifier
                                                           source:fromViewController
                                                      destination:toViewController];
    }

    if( [fromViewController vsNavigationController] != self )
    {
       UIStoryboardSegue * segue = [super segueForUnwindingToViewController:toViewController
                                                         fromViewController:fromViewController
                                                                 identifier:identifier];
        
        NAVDEBUG(@"This is not one of our controllers. System returns: %@ '%@'", segue, segue.identifier);
        return segue;
    }
    
    VSNavigationSegue *unwindStoryboardSegue = [[VSNavigationSegue alloc] initWithIdentifier:identifier
                                                                                    source:fromViewController
                                                                               destination:toViewController
                                                                                    unwind:YES
                                                                                transition:kVSTransitionFromLeft];
    
    return unwindStoryboardSegue;
}

#pragma mark Controller management

//| ----------------------------------------------------------------------------
//! Manual implementation of the topViewController property.
//! Returns the view controller at the top of the navigation stack.
//
- (UIViewController*)topViewController
{
    if (self.viewControllers.count == 0)
        return nil;
    return [self.viewControllers lastObject];
}

//| ----------------------------------------------------------------------------
//! Manual implementation of the getter for the viewControllers property.
//! Returns an array containing the view controllers currently on the
//! navigation stack.
//
- (NSArray*)viewControllers
{
    // This method is called by MainMenuViewController which then accesses
    // the first view controller in the array.  This occurs before our
    // view has been loaded (-viewDidLoad has not been called) which means
    // our initial root view controller has not been created yet (that happens
    // in -viewDidLoad).  But we must not return an empty array, so we force an
    // early load of our view here.
    [self view];
    
    return _viewControllers;
}

//| ----------------------------------------------------------------------------
//! Pushes a view controller onto the receiver’s stack and updates the display.
//
- (void)pushViewController:(UIViewController *)viewController
                transition:(VSTransitionType)transition
{
    // Replace the navigation stack with a new array that has viewController
    // apeneded to it.
    [self setViewControllers:[self.viewControllers arrayByAddingObject:viewController]
                  transition:transition];
}

- (UIViewController *)pushViewControllerNamed:(NSString *)name
                                   transition:(VSTransitionType)transition
{
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:name];
    UIStoryboardSegue * segue = [[VSNavigationSegue alloc] initWithIdentifier:@"__genericPushSegue"
                                                                       source:[self topViewController]
                                                                  destination:vc
                                                                       unwind:NO
                                                                   transition:transition];
    [segue perform];
    return vc;
}


//| ----------------------------------------------------------------------------
//! Pops view controllers until the specified view controller is at the top of the navigation stack.
//
- (NSArray *)popToViewController:(UIViewController *)viewController
                      transition:(VSTransitionType)transition
{
    // Check that viewController is in the navigation stack.
    NSUInteger indexOfViewController = [_viewControllers indexOfObject:viewController];
    if (indexOfViewController == NSNotFound)
    {
        NAVDEBUG(@"Warning Popping to non-existant view controller")
        return nil;
    }
    
    NSArray *viewControllersThatWerePopped = [_viewControllers subarrayWithRange:NSMakeRange(indexOfViewController+1, _viewControllers.count - (indexOfViewController+1))];
    NSArray *newViewControllersArray = [_viewControllers subarrayWithRange:NSMakeRange(0, indexOfViewController+1)];
    
    // Replace the navigation stack with a new array containg only the view
    // controllers up to the specified viewController.
    [self setViewControllers:newViewControllersArray transition:transition];
    
    return viewControllersThatWerePopped;
}

- (void)swapTopViewController:(UIViewController *)newTop
                        transition:(VSTransitionType)transition
{
    NSMutableArray * arr = [NSMutableArray arrayWithArray:_viewControllers];
    [arr removeLastObject];
    [arr addObject:newTop];
    [self setViewControllers:arr transition:transition];
}

//| ----------------------------------------------------------------------------
//! Equivalent to calling -setViewControllers:animated: and passing NO for the
//! animated argument.
//
- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers transition:kVSTransitionNoAnimation];
}

- (void)setViewControllers:(NSArray *)viewControllers
                transition:(VSTransitionType)transition
{
    if( _animating )
    {
        [NSObject performBlock:^{
            NAVDEBUG(@"Animation is on, delaying presentation");
            [self setViewControllers:viewControllers transition:transition];
        } afterDelay:0.3];
    }
    else
    {
        NAVDEBUG(@"Animation is off, going ahead with %@", transition);
        [self _setViewControllers:viewControllers transition:transition];
    }
}

#pragma mark Main transition and animation

#ifdef DEBUG
-(void)setAnimating:(BOOL)animating
{
    _animating = animating;
    NAVDEBUG(@"Animation is: %s", animating ? "ON" : "OFF");
}
#endif


- (void)_setViewControllers:(NSArray *)viewControllers
                 transition:(VSTransitionType)transitionName
{

    VSNavWorker * worker = [VSNavWorker new];
    
    // Compare the incoming viewControllers array to the existing navigation
    // stack, seperating the differences into two groups.
    worker.viewControllersToRemove = [_viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", viewControllers]];
    worker.viewControllersToAdd = [viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", _viewControllers]];
    
    for (UIViewController *vc in worker.viewControllersToRemove)
        [vc willMoveToParentViewController:nil];
    
    for (UIViewController *vc in worker.viewControllersToAdd)
        [self addChildViewController:vc];
    
    __weak VSNavWorker * _ww = worker;
    worker.finishRemovingViewControllers = ^{
        for (UIViewController *vc in _ww.viewControllersToRemove)
            [vc removeFromParentViewController];
    };
    
    worker.finishAddingViewControllers = ^{
        for (UIViewController *vc in _ww.viewControllersToAdd)
            [vc didMoveToParentViewController:self];
    };
    
    // The view controller presently at the top of the navigation stack.
    worker.oldTopViewController = (_viewControllers.count) ? [_viewControllers lastObject] : nil;
    // The view controller that will be at the stop of the navgation stack.
    worker.nuwTopViewController = (viewControllers.count) ? [viewControllers lastObject] : nil;
    
    _navBarHidden = NO;
    if( worker.nuwTopViewController )
    {
        worker.nuwTopViewController.navigationItem.hidesBackButton = YES;
        _navBarHidden = worker.nuwTopViewController.navigationBarHidden;
    }
    _navigationBar.hidden = _navBarHidden;
    
    VSTransitionTypeID transition = [VSNavigationViewController transitionNameToID:transitionName];
    
    BOOL doAnimation = transition != kVSTransitionNoAnimationID;
    
    // If the last object in the incoming viewControllers is the
    // already at the top of the current navigation stack then don't
    // perform any animation as it would be redundant.
    if (worker.oldTopViewController != worker.nuwTopViewController)
    {
        NAVDEBUG(@"Replacing top with : %@", worker.nuwTopViewController);
        
        VSNavAnimationBlock animation = [self animationForTransition:transitionName
                                                oldTopViewController:worker.oldTopViewController
                                                newTopViewController:worker.nuwTopViewController];
        Lamda oldAnimationDone  = nil;
        Lamda newAnimationDone = nil;
        
        if (worker.oldTopViewController)
        {
            oldAnimationDone = ^{
                //
                // Removing view here
                //
                [worker.oldTopViewController.view removeFromSuperview];
                worker.finishRemovingViewControllers();
            };
        }
        else
            worker.finishRemovingViewControllers();
        
        if (worker.nuwTopViewController)
        {
            newAnimationDone = ^{
                worker.finishAddingViewControllers();
            };
        }
        else
            worker.finishAddingViewControllers();
        
        BoolLamda complete = ^(BOOL finished) {
            if( oldAnimationDone )
                oldAnimationDone();
            if( newAnimationDone )
                newAnimationDone();
        };
        
        if( animation )
        {
            BOOL bOldShouldRasterize = worker.oldTopViewController.view.layer.shouldRasterize;
            BOOL bNewShouldRasterize = worker.nuwTopViewController.view.layer.shouldRasterize;
            worker.oldTopViewController.view.layer.shouldRasterize = YES;
            worker.nuwTopViewController.view.layer.shouldRasterize = YES;
            
            self.animating = YES;
            [UIView animateWithDuration:((doAnimation) ? 0.4 : 0) delay:0 options:0 animations:^{
                animation();
            } completion:^(BOOL finished) {
                complete(finished);
                worker.oldTopViewController.view.layer.shouldRasterize = bOldShouldRasterize;
                worker.nuwTopViewController.view.layer.shouldRasterize = bNewShouldRasterize;
                self.animating = NO;
            }];
        }
        else
        {
            complete(YES);
        }
    }
    else
    {
        NAVDEBUG(@"Top controller is already on top - no animation")
        // No animation required.
        worker.finishRemovingViewControllers();
        worker.finishAddingViewControllers();
    }
    
    _viewControllers = viewControllers;
    
    [self updateNavigationItems:transitionName];
}


-(VSNavAnimationBlock)animationForTransition:(VSTransitionType)transitionName
                        oldTopViewController:(UIViewController *)oldTopViewController
                        newTopViewController:(UIViewController *)newTopViewController
{
    VSNavAnimationBlock oldAnimation = nil;
    VSNavAnimationBlock newAnimation = nil;
    
    VSTransitionTypeID transition = [VSNavigationViewController transitionNameToID:transitionName];
    
    BOOL doAnimation = transition != kVSTransitionNoAnimationID;
    
    if (oldTopViewController)
    {
        if( doAnimation )
        {
            CGRect targetRC = oldTopViewController.view.frame;
            switch (transition) {
                case kVSTransitionFromLeftID:
                    targetRC.origin.x = targetRC.size.width;
                    break;
                    
                case kVSTransitionFromRightID:
                    targetRC.origin.x = -targetRC.size.width;
                    break;
                    
                case kVSTransitionSlideUpSwapID:
                case kVSTransitionRevealDownID:
                    targetRC.origin.y = targetRC.size.height;
                default:
                    break;
            }
            
            oldAnimation = ^{
                oldTopViewController.view.frame = targetRC;
            };
        }
    }
    
    if (newTopViewController)
    {
        BOOL bInsertBelow = NO;
        
        CGRect startingRC = [self frameForTopViewController];
        CGRect targetRC = startingRC;
        
        if( doAnimation )
        {
            switch (transition) {
                case kVSTransitionFromLeftID:
                    startingRC.origin.x = -targetRC.size.width;
                    break;
                case kVSTransitionFromRightID:
                    startingRC.origin.x = targetRC.size.width;
                    break;
                case kVSTransitionSlideUpSwapID:
                case kVSTransitionSlideUpID:
                    startingRC.origin.y = targetRC.size.height;
                    break;
                case kVSTransitionRevealDownID:
                    bInsertBelow = YES;
                    doAnimation = NO;
                default:
                    break;
            }
        }
        
        newTopViewController.view.frame = startingRC;
        //
        // Inserting views here
        //
        if( oldTopViewController && bInsertBelow )
            [self.view insertSubview:newTopViewController.view belowSubview:oldTopViewController.view];
        else
            [self.view addSubview:newTopViewController.view];
        
        if( doAnimation )
        {
            newAnimation = ^{
                newTopViewController.view.frame = targetRC;
            };
        }
    }
    
    if( oldAnimation || newAnimation )
    {
        return ^{
            if( oldAnimation )
                oldAnimation();
            if( newAnimation )
                newAnimation();
        };
    }
    
    return nil;
}

#pragma mark NavigationBar and Items

-(void)updateNavigationItems:(VSTransitionType)transitionName
{
    // Update the stack of navigation items for the _navigationBar to
    // reflect the new navigation stack.
    NSMutableArray *newNavigationItemsArray = [NSMutableArray arrayWithCapacity:_viewControllers.count];
    for (UIViewController *vc in _viewControllers)
        [newNavigationItemsArray addObject:vc.navigationItem];
    
    if( newNavigationItemsArray.count > 1 )
    {
        UIViewController * top = _viewControllers.lastObject;
        if( top.navigationItem.leftBarButtonItems.count == 0 )
        {
            UINavigationItem * backItem = newNavigationItemsArray[ _viewControllers.count - 2 ];
            
            [self addBackButtonForController:top
                                       title:backItem.title
                                  transition:transitionName
                                       block:^(VSNavigationViewController *me, id sender)
             {
                 UIViewController * top = me->_viewControllers.lastObject;
                 
                 if( [sender isKindOfClass:[UIStoryboardSegue class]] )
                     return;
                 
                 @try {
                     [top performSegueWithIdentifier:kSegueBackButtonUnwind sender:sender];
                 }
                 @catch(NSException *exp) {
                     UIViewController * vc = me->_viewControllers[me->_viewControllers.count - 2];
                     UIStoryboardSegue *segue = [me segueForUnwindingToViewController:vc
                                                                   fromViewController:top
                                                                           identifier:@"__genericUnwind"];
                     [segue perform];
                 }
             }];
        }
    }
    [_navigationBar setItems:newNavigationItemsArray animated:!_navBarHidden];
}

-(void)performBack
{
    [self invokBackItem:nil];
}

-(void)invokBackItem:(id)sender
{
    UIViewController * top = [self topViewController];
    NSMutableArray * arr = [top backButtonHooks];
    if( arr )
    {
        for( VSNavActionBlock block in arr )
        {
            block(self,sender);
        }
    }
}

-(void)addBackButtonForController:(UIViewController *)vc
                            title:(NSString *)title
                       transition:(VSTransitionType)transitionName
                            block:(VSNavActionBlock)block
{
#define kBarButtonSize 20

    [vc.backButtonHooks addObject:[block copy]];
    
    if( vc.backButtonHidden )
        return;
    
    UIButton * button = [[UIButton alloc] initWithFrame:(CGRect){0,0,kBarButtonSize,kBarButtonSize}];
    button.showsTouchWhenHighlighted = YES;

    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:button.titleLabel.font.fontName size:15];

    NSString * imageName = nil;
    VSTransitionTypeID transition = [VSNavigationViewController transitionNameToID:transitionName];
    switch (transition) {
        case kVSTransitionSlideUpID:
        case kVSTransitionSlideUpSwapID:
            imageName = kImageDown;
            break;
        default:
            imageName = kImageBackArrow;
    }
    UIImage * image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];

    [button sizeToFit];
    UIColor * textColor;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        textColor = _navigationBar.tintColor;
        [button setTintColor:textColor];
    }
    else
    {
        textColor = _navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
    }
    
    [button setTitleColor:textColor forState:UIControlStateNormal];
    
    
    [button addTarget:self action:@selector(invokBackItem:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithCustomView:button];
    bbi.style = UIBarButtonItemStylePlain;
    [vc.navigationItem setLeftBarButtonItems:@[bbi] animated:YES];
}


@end

#pragma mark -
#pragma mark Custom segues (implementations)

/**
 *  Segue used to embed your custom view controllers into the navigation
 *  system. See VSNavigationViewController for how to use this segue.
 */
@implementation VSRootViewControllerSegue

- (void)perform
{
    VSNavigationViewController *containerVC = (VSNavigationViewController*)self.sourceViewController;
    
    NSArray *viewControllers = @[self.destinationViewController];
    
    [containerVC setViewControllers:viewControllers];
}

@end



@implementation VSNavigationSegue

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination
{
    return [self initWithIdentifier:identifier
                             source:source
                        destination:destination
                             unwind:NO
                         transition:kVSTransitionFromRight];
}

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination
                 unwind:(BOOL)unwind
             transition:(VSTransitionType)transition
{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if( self )
    {
        NAVDEBUG(@"Created segue %@ (%s)", identifier, unwind ? "unwind" : "push");
        _transition = transition;
        _unwind = unwind;
    }
    return self;
}

-(void)oppositeTransition
{
    VSTransitionTypeID transition = [VSNavigationViewController transitionNameToID:_transition];
    switch (transition) {
        case kVSTransitionFromRightID:
            _transition = kVSTransitionFromLeft;
            break;
        case kVSTransitionFromLeftID:
            _transition = kVSTransitionFromRight;
            break;
        case kVSTransitionSlideUpID:
            _transition = kVSTransitionRevealDown;
            break;
        case kVSTransitionRevealDownID:
            _transition = kVSTransitionSlideUp;
        default:
            break;
    }
}
//| ----------------------------------------------------------------------------
//  This segue does not implement the transition animation.  Instead, it calls
//  -pushViewController: or -popToViewController: of the parent
//  navigation controller, which actually performs the transition.
//
- (void)perform
{
    VSNavigationViewController *containerVC = [self navigationController];
    if (_unwind)
    {
        self.transition = [self.sourceViewController lastTransitionType];
        [self oppositeTransition];
        [containerVC invokBackItem:self];
        [containerVC popToViewController:self.destinationViewController transition:_transition];
    }
    else
    {
        [self.destinationViewController setLastTransitionType:_transition];
        [containerVC pushViewController:self.destinationViewController transition:_transition];
    }
    
}

-(VSNavigationViewController *)navigationController
{
    VSNavigationViewController * nav = ((UIViewController *)self.sourceViewController).vsNavigationController;
    if( !nav )
        nav = ((UIViewController *)self.destinationViewController).vsNavigationController;
    
    return nav;
}
@end

@implementation VSDismissAndUnwindSegue

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination
{
    return [self initWithIdentifier:identifier
                             source:source
                        destination:destination
                             unwind:YES
                         transition:kVSTransitionNoAnimation];
}

-(void)perform
{
    VSNavigationViewController *containerVC = [self navigationController];

    [containerVC invokBackItem:self];
    [containerVC popToViewController:self.destinationViewController transition:self.transition];
    [containerVC dismissViewControllerAnimated:YES completion:nil];
}

@end
@implementation VSSlideUpSegue

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier
                              source:source
                         destination:destination
                              unwind:NO
                          transition:kVSTransitionSlideUp];
}

@end


static void * kLastTransitionKey = &kLastTransitionKey;
static void * kBackUnwindSegueKey = &kBackUnwindSegueKey;
static void * kBackButtonHooks = &kBackButtonHooks;

@implementation UIViewController (VSNavigator)

-(NSMutableArray *)backButtonHooks
{
    NSMutableArray * arr = [self associatedValueForKey:kBackButtonHooks];
    if( !arr )
    {
        arr = [NSMutableArray new];
        [self associateValue:arr withKey:kBackButtonHooks];
    }
    return arr;
}

-(BOOL)hasBackButtonHooks
{
    return [self associatedValueForKey:kBackButtonHooks] != nil;
}

-(void)setLastTransitionType:(VSTransitionType)type
{
    [self associateValue:type withKey:kLastTransitionKey];
}

-(VSTransitionType)lastTransitionType
{
    return [self associatedValueForKey:kLastTransitionKey];
}

-(void)setBackUnwindSegue:(NSString *)identifier
{
    [self associateValue:identifier withKey:kBackUnwindSegueKey];
}

-(NSString *)backUnwindSegue
{
    return [self associatedValueForKey:kBackUnwindSegueKey];
}

-(BOOL)navigationBarHidden
{
    return NO;
}

-(BOOL)backButtonHidden
{
    return NO;
}

-(VSNavigationViewController *)vsNavigationController
{
    UIViewController * vc = self;
    Class navClass = [VSNavigationViewController class];
    while( vc )
    {
        if( [vc isKindOfClass:navClass] )
            return (VSNavigationViewController *)vc;
        vc = vc.parentViewController;
    }
    return nil;
}

-(void)performSystemSegue:(NSString *)identifier sender:(id)sender
{
    if( self.presentedViewController )
    {
        [NSObject performBlock:^{
            [self performSystemSegue:identifier sender:sender];
        } afterDelay:0.2];
        return;
    }
    [self performSegueWithIdentifier:identifier sender:sender];
}
@end


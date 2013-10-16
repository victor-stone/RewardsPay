//
//  VSViewController.h
//  VSNavigation
//
//  Created by victor on 08/01/13
//  Copyright (c) 2013 AOTK. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef kImageBackArrow
#define kImageBackArrow @"kImageBackArrow"
#endif

#ifndef kImageDown
#define kImageDown @"kImageDown"
#endif

#define VSTransitionType NSString *

#ifndef VSNAV_STRING
#define VSNAV_STRING(name) extern NSString * const name;
#endif

#ifdef DEBUG
#ifndef NAVDEBUG
#define NAVDEBUG(...) NSLog(__VA_ARGS__)
#endif
#else
#define NAVDEBUG(...)
#endif

VSNAV_STRING(kSegueRootViewController);
VSNAV_STRING(kSegueBackButtonUnwind);

VSNAV_STRING(kVSTransitionNoAnimation);
VSNAV_STRING(kVSTransitionFromRight);
VSNAV_STRING(kVSTransitionFromLeft);
VSNAV_STRING(kVSTransitionSlideUp);
VSNAV_STRING(kVSTransitionRevealDown);
VSNAV_STRING(kVSTransitionSlideUpSwap);


typedef void (^VSNavActionBlock)(id,id);
typedef void (^VSNavAnimationBlock)();

/**
 *  A Navigation scheme similar to UINavigationController but with
 *  more options and flexibility.
 *
 *  Use this class in conjunction with a storyboard, VSNavigatorSegue
 *  (and derivations) and optionally VSTabNavigator.
 *
 *  In IB: 
 *    1. Create a UIViewController, assign this class (or derivation)
 *       to it. 
 *    2. Remove the view from inside the VC.
 *    3. Create your "root" viewcontroller
 *    4. Drag a segue from this controller to yours, make a custom
 *       segue of type VSRootViewControllerSegue
 *    5. Name it "kSegueRootViewController" exactly
 *    6. Now you can create an entire tree of view controllers
 *       connecting them with VSNavigatorSegues or derivations
 *
 *  The navigator supports unwind segues. See updateNavigationItems:
 *  for the default implementation of the 'back' button.
 */
@interface VSNavigationViewController : UIViewController

@property (readonly) UINavigationBar *navigationBar;

- (UIViewController*)topViewController;

- (void)pushViewController:(UIViewController *)viewController
                transition:(VSTransitionType)transition;

- (UIViewController *)pushViewControllerNamed:(NSString *)name
                                   transition:(VSTransitionType)transition;

- (NSArray *)popToViewController:(UIViewController *)viewController
                      transition:(VSTransitionType)transition;

- (void)swapTopViewController:(UIViewController *)newTop
                   transition:(VSTransitionType)transition;

-(void)performBack;

@property (nonatomic) BOOL animating;

// For deriving:

/**
 *  Method for returning an animation block to use during a navigation transition
 *
 *  Derivations that override this method and don't call the base class default
 *  implementation are responsible for adding the newTopViewController.view
 *  to self.view. This is done to give the animation routine maximum flexibility
 *  on the layering of the views during the transition.
 *
 *  Derivations that override this method and don't call the base class default
 *  implementation IS NOT and MUST NOT remove the oldTopViewController's view
 *  from self.view
 *
 *  @param transitionName       The type of transition expected.
 *  @param oldTopViewController The view controller being covered (push) or removed (unwind)
 *  @param newTopViewController The view controller being newly presented (push) or uncovered (unwind)
 *
 *  @return Animation block that will be used to transition between controllers
 */
-(VSNavAnimationBlock)animationForTransition:(VSTransitionType)transitionName
                        oldTopViewController:(UIViewController *)oldTopViewController
                        newTopViewController:(UIViewController *)newTopViewController;


/**
 *  Updates the navigationItems in the navigationBar, installs a default
 *  '< [Back]' button into the top controller with the name of the previous 
 *  item in the navigation stack.
 *  
 *  @param transitionName The transition type that was used to present the current top controller.
 */
-(void)updateNavigationItems:(VSTransitionType)transitionName;

/**
 *  Request to add a back button to a view controller
 *
 *  Derivations can override this method but if they don'e call the base class
 *  default implementation they are responsible for adding the UIBarButtonItem
 *  to the navigator bar.
 *
 *  Derivations can use the `transitionName` parameter as a hint to what
 *  kind of back button should be presented.
 *
 *  The logic behind the default block that is passed to this method is as follows:
 *  - If the top controller has a segue with the exact name "kSegueBackButtonUnwind"
 *    then that will be used
 *  - If no such segue is found a generic VSNavigatorSegue is created in 'unwind'
 *    mode and the top controller is popped off the stack to reveal the one below
 *    it. See the VSNavigorSegue -perform method for how that will behave.
 *
 *  This block (or any wrapper or replacement that is used to call the base class
 *  implementation) will be added to the viewController using the 
 *  UIViewController(VSNavigator) category method -backButtonHooks.
 *
 *  @param vc             The controller to add the button
 *  @param title          The default title to use. Default is the title of the previous controller in the stack.
 *  @param transitionName The transition type that was used to present the current top controller.
 *  @param block          The default block for the back button.
 */
-(void)addBackButtonForController:(UIViewController *)vc
                            title:(NSString *)title
                       transition:(VSTransitionType)transitionName
                            block:(VSNavActionBlock)block;

@end

@interface VSNavigationSegue : UIStoryboardSegue
@property (nonatomic) BOOL unwind;
@property (nonatomic) VSTransitionType transition;

-(VSNavigationViewController *)navigationController;

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination;

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination
                 unwind:(BOOL)unwind
             transition:(VSTransitionType)transition;
@end

@interface VSSlideUpSegue : VSNavigationSegue

@end


@interface UIViewController (VSNavigator)
-(void)setLastTransitionType:(VSTransitionType)type;
-(VSTransitionType)lastTransitionType;
-(void)setBackUnwindSegue:(NSString *)backUnwindSegue;
-(NSString *)backUnwindSegue;
-(NSMutableArray *)backButtonHooks;
-(BOOL)navigationBarHidden;
-(VSNavigationViewController *)vsNavigationController;
-(void)performSystemSegue:(NSString *)identifier sender:(id)sender;
@end



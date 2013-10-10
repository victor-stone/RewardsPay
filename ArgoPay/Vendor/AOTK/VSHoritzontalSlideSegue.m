//
//  VSImageTweaks.h
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//
// Some of this is based on
// http://jmsliu.com/1249/create-push-segue-animation-without-uinavigation-controller.html
//
#import "VSHoritzontalSlideSegue.h"
#import "APAppDelegate.h"
#import "APDebug.h"
#import "APStrings.h"

static void *kSlideSegueDictKey     = &kSlideSegueDictKey;
static void *kBackslideSegueNameKey = &kBackslideSegueNameKey;

@implementation UIViewController (SlideSegue)

-(void) performForwardSlideSegue:(NSString *)forward back:(NSString *)back
{
    if( back )
    {
        APLOG(kDebugViews, @"Performating FORWARD segue: %@ -> %@ on %@", forward, back, self);
        NSMutableDictionary *backslides = [self associatedValueForKey:kSlideSegueDictKey];
        if( !backslides )
        {
            backslides = [NSMutableDictionary new];
            [self associateValue:backslides withKey:kSlideSegueDictKey];
        }
        backslides[forward] = back;
    }
    [self performSegueWithIdentifier:forward sender:self];
}

-(IBAction)performBackSlideSegue:(id)sender
{
    APLOG(kDebugViews, @"Performing BACK seque: %@", self);
    [self slideBetweenVC:self.presentingViewController isDismiss:YES];
    /*
    NSAssert(back != nil, @"Backsliding seque is blank. Did you forget to call -assignBackslideSequeName?");
    [self performSegueWithIdentifier:back sender:sender];
     */
}

-(void)slideBetweenVC:(UIViewController *)desViewController isDismiss:(BOOL)_isDismiss
{
    UIViewController *srcViewController = self;
    
    UIView *srcView = [srcViewController view];
    UIView *desView = [desViewController view];
    
    desView.transform = srcView.transform;
    desView.bounds = srcView.bounds;
    
    BOOL _isLandscapeOrientation = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    
    if(_isLandscapeOrientation)
    {
        if(_isDismiss)
        {
            desView.center = CGPointMake(srcView.center.x, srcView.center.y  - srcView.frame.size.height);
        }
        else
        {
            desView.center = CGPointMake(srcView.center.x, srcView.center.y  + srcView.frame.size.height);
        }
    }
    else
    {
        if(_isDismiss)
        {
            desView.center = CGPointMake(srcView.center.x - srcView.frame.size.width, srcView.center.y);
        }
        else
        {
            desView.center = CGPointMake(srcView.center.x + srcView.frame.size.width, srcView.center.y);
        }
    }
    
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    APLOG(kDebugViews, @"------------------------------------- DUMPING WINDOWS ----------------------------", 0);
    for( UIWindow *window in windows )
    {
        APDUMPVIEW(window);
    }
    UIWindow *mainWindow = [windows objectAtIndex:0];
    [mainWindow addSubview:desView];
    
    // slide newView over oldView, then remove oldView
    [UIView animateWithDuration:0.3
                     animations:^{
                         desView.center = CGPointMake(srcView.center.x, srcView.center.y);
                         
                         if(_isLandscapeOrientation)
                         {
                             if(_isDismiss)
                             {
                                 srcView.center = CGPointMake(srcView.center.x, srcView.center.y + srcView.frame.size.height);
                             }
                             else
                             {
                                 srcView.center = CGPointMake(srcView.center.x, srcView.center.y - srcView.frame.size.height);
                             }
                         }
                         else
                         {
                             if(_isDismiss)
                             {
                                 srcView.center = CGPointMake(srcView.center.x + srcView.frame.size.width, srcView.center.y);
                             }
                             else
                             {
                                 srcView.center = CGPointMake(srcView.center.x - srcView.frame.size.width, srcView.center.y);
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         if( _isDismiss )
                             [desViewController dismissViewControllerAnimated:NO completion:nil];
                         else
                             [srcViewController presentViewController:desViewController animated:NO completion:nil];
                         APDUMPVCS;
                     }];
    
}
@end

@implementation VSHoritzontalSlideSegue

- (void) perform
{
    APDUMPVCS;
    
    UIViewController *desViewController = (UIViewController *)self.destinationViewController;
    UIViewController *srcViewController = (UIViewController *)self.sourceViewController;
    [srcViewController slideBetweenVC:desViewController isDismiss:NO];
}

@end

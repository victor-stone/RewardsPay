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
//    [self slideBetweenVC:self.presentingViewController isDismiss:YES];
    NSString *back = [self associatedValueForKey:kBackslideSegueNameKey];
    APLOG(kDebugViews, @"Performing BACK %@ seque: %@", back, self);
    NSAssert(back != nil, @"Backsliding seque is blank. Did you forget to call -assignBackslideSequeName?");
    [self performSegueWithIdentifier:back sender:sender]; // this better be an unwind segue
}

-(void)slideBetweenVC:(UIViewController *)desViewController isDismiss:(BOOL)isDismiss
{
    UIViewController *srcViewController = self;
    
    UIView *srcView = [srcViewController view];
    UIView *desView = [desViewController view];
    
    desView.transform = srcView.transform;
    desView.bounds = srcView.bounds;
    
    BOOL isLandscapeOrientation = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    
    if(isLandscapeOrientation)
    {
        if(isDismiss)
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
        if(isDismiss)
        {
            desView.center = CGPointMake(srcView.center.x - srcView.frame.size.width, srcView.center.y);
        }
        else
        {
            desView.center = CGPointMake(srcView.center.x + srcView.frame.size.width, srcView.center.y);
        }
    }
    
    
    APDUMPVIEW(nil);
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    UIWindow *mainWindow = [windows objectAtIndex:0];
    UIView *zero = mainWindow.subviews[0];
    [mainWindow addSubview:desView];
    
    // slide newView over oldView, then remove oldView
    [UIView animateWithDuration:0.3
                     animations:^
    {
        zero.backgroundColor = [UIColor purpleColor];
        
        desView.center = CGPointMake(srcView.center.x, srcView.center.y);
        
        if(isLandscapeOrientation)
        {
            if(isDismiss)
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
            if(isDismiss)
            {
                srcView.center = CGPointMake(srcView.center.x + srcView.frame.size.width, srcView.center.y);
            }
            else
            {
                srcView.center = CGPointMake(srcView.center.x - srcView.frame.size.width, srcView.center.y);
            }
        }
    }
    completion:^(BOOL finished)
    {
         if( isDismiss )
             [desViewController dismissViewControllerAnimated:NO completion:nil];
         else
             [srcViewController presentViewController:desViewController animated:NO completion:nil];
         //APDUMPVCS;
     }];
    
}
@end

@implementation VSHoritzontalSlideSegue

- (void) perform
{
   // APDUMPVCS;
    
    UIViewController *src = (UIViewController *)self.sourceViewController;
    UIViewController *dest = (UIViewController *)self.destinationViewController;
    bool isDismiss = NO;
    NSString *back = [src associatedValueForKey:kBackslideSegueNameKey];
    if( [back isEqualToString:self.identifier] )
    {
        isDismiss = YES;
    }
    else
    {
        NSDictionary * segueDictionary = [src associatedValueForKey:kSlideSegueDictKey];
        back = segueDictionary[self.identifier];
        if( back )
            [dest associateValue:back withKey:kBackslideSegueNameKey];
    }
    APLOG(kDebugViews, @"Performing (Dismiss: %d) segue from: %@ -> %@ called %@", isDismiss, src,dest,self.identifier);
    [src slideBetweenVC:dest isDismiss:isDismiss];
}

@end

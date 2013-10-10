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
    NSString *back = [self associatedValueForKey:kBackslideSegueNameKey];
    APLOG(kDebugViews, @"Performing BACK seque: %@ on %@", back, self);
    NSAssert(back != nil, @"Backsliding seque is blank. Did you forget to call -assignBackslideSequeName?");
    [self performSegueWithIdentifier:back sender:sender];
}

@end
@implementation VSHoritzontalSlideSegue {
    BOOL _isLandscapeOrientation;
    BOOL _isDismiss;
}

- (void) perform
{
    UIViewController *desViewController = (UIViewController *)self.destinationViewController;
    
    UIView *srcView = [(UIViewController *)self.sourceViewController view];
    UIView *desView = [desViewController view];
    
    desView.transform = srcView.transform;
    desView.bounds = srcView.bounds;
    
    [self setupDirection];
    
    _isLandscapeOrientation = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);

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
                             [self.sourceViewController dismissViewControllerAnimated:NO completion:nil];
                         else
                             [self.sourceViewController presentViewController:desViewController animated:NO completion:nil];
                     }];
}

-(void)setupDirection
{
    _isDismiss = NO;
    NSMutableDictionary *backslides = [self.sourceViewController associatedValueForKey:kSlideSegueDictKey];
    
    // Controllers that support 'push' slide style have a dictionary
    if( backslides )
    {
        NSString *back = backslides[self.identifier];
        
        // If this segue is listed, then we are indeed a push
        if( back )
        {
            APLOG(kDebugViews, @"Associating %@ with destination %@", back, self.destinationViewController);
            [self.destinationViewController associateValue:back withKey:kBackslideSegueNameKey];
        }
        else
        {
            // There is no back in this dictionary, that means that even though
            // the source controller *can* be a pusher, in this case, we are
            // actually returning
            _isDismiss = YES;
        }
    }
    else
    {
        // the source is something we pushed on to the destination.
        // now we are returning.
        _isDismiss = YES;
    }
}


@end

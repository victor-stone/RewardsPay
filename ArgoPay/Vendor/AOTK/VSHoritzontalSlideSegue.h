//
//  VSHorizontalSlideSegue
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SlideSegue)
/**
 *  Do this in response to button tap to do a push
 *
 *  @param forward Name of segue to perform now
 *  @param back    Name of segue to perform from dest controller to perform a 'back'
 */
-(void) performForwardSlideSegue:(NSString *)forward back:(NSString *)back;

/**
 *  Hook this up to the back button of a pushed VC
 *
 *  @param sender Meh
 */
-(IBAction)performBackSlideSegue:(id)sender;

@end


@interface VSHoritzontalSlideSegue : UIStoryboardSegue
@end

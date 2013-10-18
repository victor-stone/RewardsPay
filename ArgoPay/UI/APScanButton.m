//
//  APScanButton.m
//  ArgoPay
//
//  Created by victor on 10/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APScanButton.h"

@implementation APScanButton{
    UIColor * _defaultColor;
}

-(void)setSelected:(BOOL)selected
{
    if( !_defaultColor )
        _defaultColor = self.backgroundColor;
    
    BOOL oldValue = self.selected;
    if( oldValue != selected )
    {
        [super setSelected:selected];
        UIImage * image = [self imageForState:self.state];
        [self setImage:nil forState:self.state];
        self.hidden = YES;
        if( selected )
        {
            self.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            self.backgroundColor = _defaultColor;
        }
        self.hidden = NO;
        [self setImage:image forState:self.state];
    }
}

- (id<CAAction>)actionForLayer:(CALayer *)theLayer
                        forKey:(NSString *)theKey {
    
    CATransition *theAnimation = nil;
    
    NSString * matches = @"hidden"; // kCAOnOrderIn
    if ( [theKey isEqualToString:matches] ) {
        
        theAnimation = [[CATransition alloc] init];
        theAnimation.duration = 0.5;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        if( self.selected )
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

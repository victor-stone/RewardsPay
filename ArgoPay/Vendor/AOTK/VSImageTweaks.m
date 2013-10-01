//
//  VSImageTweaks.m
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import "VSImageTweaks.h"

@implementation UIImage (Tint)

- (UIImage *)tint:(UIColor *)tint
{
    NSAssert(tint != nil, @"tint must not be nil");
    
    CGRect bounds = (CGRect){ {0,0}, [self size] };
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);
    
    [tint setFill];
    
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation UIImageView (Tint)

-(void)tint:(UIColor *)tint
{
    [self setImage:[self.image tint:tint]];
}

@end

@implementation UIButton (Tint)

-(void)setBackgroundImage:(NSString *)name inset:(NSUInteger)inset tint:(UIColor *)tint
{
    UIImage * bg = [[[UIImage imageNamed:name]
                    resizableImageWithCapInsets:UIEdgeInsetsMake(inset,inset,inset,inset)
                    resizingMode:UIImageResizingModeStretch] tint:tint];
    [self setBackgroundImage:bg forState:UIControlStateNormal];
}

-(void)tintForeground:(UIColor *)tint
{
    UIImage * img = [self.imageView.image tint:tint];
    [self setImage:img forState:UIControlStateNormal];
}

-(void)tintBackground:(UIColor *)tint
{
    UIImage * img = [[self backgroundImageForState:UIControlStateNormal] tint:tint];
    [self setBackgroundImage:img forState:UIControlStateNormal];
}
@end


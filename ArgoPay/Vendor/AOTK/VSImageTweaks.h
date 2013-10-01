//
//  VSImageTweaks.h
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (Tint)
- (UIImage *)tint:(UIColor *)tint;
@end

@interface UIImageView (Tint)
-(void)tint:(UIColor *)tint;
@end

@interface UIButton (Tint)
-(void)tintForeground:(UIColor *)tint;
-(void)tintBackground:(UIColor *)tint;
-(void)setBackgroundImage:(NSString *)name inset:(NSUInteger)inset tint:(UIColor *)tint;
@end


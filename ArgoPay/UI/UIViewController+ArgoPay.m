//
//  UIViewController+ArgoPay.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "UIViewController+ArgoPay.h"
#import "APStrings.h"


@implementation UIView (argopay)

-(id)firstResponder
{
    if( [self isFirstResponder] )
        return self;
    for( UIView * view in self.subviews )
    {
        id found = [view firstResponder];
        if( found )
            return found;
    }
    return nil;
}
@end

@implementation UIViewController (ArgoPay)

void * kTargetMapAssociationKey = &kTargetMapAssociationKey;

-(void)invokeMenuItem:(id)sender
{
    NSMutableDictionary * _map = [self associatedValueForKey:kTargetMapAssociationKey];
    NSObject * obj = sender;
    APMenuBlock block = _map[@(obj.hash)];
    block(self,sender);
}


-(NSMutableDictionary *)targetMap
{
    NSMutableDictionary * _map = [self associatedValueForKey:kTargetMapAssociationKey];
    if( !_map )
    {
        _map = [NSMutableDictionary new];
        [self associateValue:_map withKey:kTargetMapAssociationKey];
    }
    return _map;
}

-(UIBarButtonItem *)barButtonForImage:(NSString *)imgName
                                title:(NSString *)title
                                block:(APMenuBlock)block;
{
    UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imgName]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(invokeMenuItem:)];
    NSMutableDictionary * _map = self.targetMap;
    _map[@(bbi.hash)] = [block copy];
    return bbi;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)iOrientation {
    return (iOrientation == UIInterfaceOrientationPortrait);
}

-(void)adjustViewForiOS7
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [self setNeedsStatusBarAppearanceUpdate];
        
        UIView *view = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, 320, 20 }];
        view.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:view];
        
        for( NSLayoutConstraint *lcx in self.view.constraints )
        {
            if( lcx.secondItem == self.view && lcx.firstAttribute == NSLayoutAttributeTop )
            {
                lcx.constant += 20;
                APLOG(kDebugViews, @"Shifting %@ in %@",lcx.firstItem, self);
                break;
            }
        }

    }
}

- (id)firstResponder
{
    return [self.view firstResponder];
}

@end

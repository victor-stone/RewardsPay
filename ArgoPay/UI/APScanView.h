//
//  APScanView.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

typedef void (^APScannerDoneBlock)(UIViewController *);

@interface APScanResult : NSObject
@property (nonatomic,strong) UIImage * image;
@property (nonatomic,strong) NSString * text;
@end

@protocol APScanDelegate <NSObject>
-(UIViewController *)scanHostViewController;
-(void)toggleScanner:(APScannerDoneBlock)block;
@end

@interface APScanRequestWatcher : NSObject<ZBarReaderDelegate>
-(id)initWithDelegate:(id<APScanDelegate>)delegate;
-(UIViewController *)request;
@end

//
//  APScanView.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface APScanResult : NSObject
@property (nonatomic,strong) UIImage * image;
@property (nonatomic,strong) NSString * text;
@end

#ifndef AP_SCAN_DECLS
extern APScanResult *AP_EMPTY_SCAN_RESULT;
#endif

@interface APScanRequestWatcher : NSObject<ZBarReaderDelegate>

@end

@interface APScanViewController : UIViewController

@property (nonatomic) bool enabled;

@property (weak,nonatomic) UIViewController *homeController;
@end

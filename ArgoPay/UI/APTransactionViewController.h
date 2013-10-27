//
//  APSharedTransaction.h
//  ArgoPay
//
//  Created by victor on 10/15/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APTransaction.h"

@class APPopup;

@interface APTransactionViewController : UIViewController
@property (nonatomic,strong) NSString *transID;
@property (nonatomic,strong) NSString *scanResultText;
@property (nonatomic,strong) UIImage * scanResultImage;
@property (nonatomic,strong) APTransactionStatusResponse *statusResponse;
@property (nonatomic,strong) APPopup *popup;

-(void)storeCameraResults:(id)cameraViewController;
-(void)clearTransaction;
-(void)attemptTransaction;
@end


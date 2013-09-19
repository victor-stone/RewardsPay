//
//  APScanView.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#define AP_SCAN_DECLS
#import "APScanView.h"
#import "APStrings.h"
#import "ZBarSDK.h"


@implementation APScanResult
@end

APScanResult * AP_EMPTY_SCAN_RESULT;

@implementation APScanRequestWatcher {
    ZBarReaderViewController * _reader;
}

-(id)init
{
    self = [super init];
    if( !self )
        return nil;
    
    [self registerForBroadcast:kNotifyRequestScanner block:^(APScanRequestWatcher *me, UIViewController *caller) {
        if( me->_reader )
        {
            [me closeReader:nil];
        }
        else
        {
            [NSObject performBlock:^{
                [me request:caller];
            } afterDelay:0.2];
        }
    }];
    return self;
}

-(UIViewController *)request:(UIViewController *)caller
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    [reader.scanner setSymbology: 0
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    [reader.scanner setSymbology: ZBAR_QRCODE
                          config: ZBAR_CFG_ENABLE
                              to: 1];
    reader.readerView.zoom = 1.0;
    return reader;
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol * sym = nil;
    for( sym in results) break;
    APScanResult * result = [APScanResult new];
    result.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    result.text = sym.data;
    [self closeReader:result];
}

-(void)closeReader:(APScanResult *)result
{
    if( !AP_EMPTY_SCAN_RESULT )
        AP_EMPTY_SCAN_RESULT = [APScanResult new];
        
    [self broadcast:kNotifyScanComplete payload:result ?: AP_EMPTY_SCAN_RESULT];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self closeReader:nil];
}

@end


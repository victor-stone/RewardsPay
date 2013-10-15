//
//  APTransactionViewController.m
//  ArgoPay
//
//  Created by victor on 10/15/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "VSNavigationViewController.h"
#import "ZBarSDK.h"
#import "APDebug.h"
#import "APStrings.h"
/**
 *  Wrapper for ZBar VC which has a bug (missing auto release)
 *
 * Discussion here:
 *
 * http://sourceforge.net/p/zbar/discussion/1072195/thread/df4c215a/
 *
 */
@interface APCamera : ZBarReaderViewController<ZBarReaderDelegate>
@property (nonatomic,strong) NSString *resultText;
@property (nonatomic,strong) UIImage * resultImage;
@end

@implementation APCamera
APLOGRELEASE
- (void) loadView
{
    self.view = [[UIView alloc]
                 initWithFrame: CGRectMake(0, 0, 320, 480)];
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.wantsFullScreenLayout = NO;
    self.readerDelegate = self;
    [self.scanner setSymbology: 0
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    [self.scanner setSymbology: ZBAR_QRCODE
                          config: ZBAR_CFG_ENABLE
                              to: 1];
    self.readerView.zoom = 0.8;
    
}

-(BOOL)navigationBarHidden
{
    return YES;
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol * sym = nil;
    for( sym in results) break;
    self.resultImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    self.resultText = sym.data;
    APLOG(kDebugScan, @"Got scan result %@", self.resultText);

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
}

@end


@interface APTransactionViewController : UIViewController
@property (nonatomic,strong) NSString *resultText;
@property (nonatomic,strong) UIImage * resultImage;

@end


@implementation APTransactionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSegueWithIdentifier:kSeguePushCamera sender:self];
	
}

-(IBAction)unwindFromCamera:(UIStoryboardSegue *)segue
{
    APCamera * camera = segue.sourceViewController;
    _resultImage = camera.resultImage;
    _resultText  = camera.resultText;
    [self performSegueWithIdentifier:kSegueTransactionBill sender:self];
}

-(IBAction)unWindFromBillAccept:(UIStoryboardSegue *)segue
{
    
}

-(IBAction)unWindFromBillCancel:(UIStoryboardSegue *)segue
{
    
}

@end

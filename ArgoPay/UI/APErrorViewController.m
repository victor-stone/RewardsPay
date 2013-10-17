//
//  APErrorViewController.m
//  ArgoPay
//
//  Created by victor on 9/23/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

@class APErrorViewController;

typedef BOOL (^APErrorAlertBlock)(APErrorViewController *errorViewController);

@interface APErrorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *bottomMessage;
@property (weak, nonatomic) IBOutlet UILabel *mainMessage;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic,strong) APErrorAlertBlock alertBlock;
@property (nonatomic,strong) NSError *errorObj;
@end

@implementation APErrorViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( _alertBlock )
    {
        if( !_alertBlock(self) )
            _alertBlock = nil;
    }
}

-(void)setErrorObj:(NSError *)error
{
    _errorObj = error;
    [self view];
    _mainMessage.text = _errorObj.localizedDescription;
    _bottomMessage.text = _errorObj.localizedRecoverySuggestion;
}

@end

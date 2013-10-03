//
//  APErrorViewController.m
//  ArgoPay
//
//  Created by victor on 9/23/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

@interface APErrorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *bottomMessage;
@property (weak, nonatomic) IBOutlet UILabel *mainMessage;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic,strong) NSError *errorObj;
@end

@implementation APErrorViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self argoPayIze];
    self.errorObj = _errorObj;
    [self addBackButton:_navBar];
}

-(void)setErrorObj:(NSError *)error
{
    _errorObj = error;
    _mainMessage.text = _errorObj.localizedDescription;
    _bottomMessage.text = _errorObj.localizedRecoverySuggestion;
}

@end

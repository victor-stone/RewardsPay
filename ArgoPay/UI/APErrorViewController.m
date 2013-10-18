//
//  APErrorViewController.m
//  ArgoPay
//
//  Created by victor on 9/23/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "VSNavigationViewController.h"

@class APErrorViewController;

@interface APErrorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *bottomMessage;
@property (weak, nonatomic) IBOutlet UILabel *mainMessage;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic,strong) UIAlertView * alertView;
@property (nonatomic,strong) NSError *errorObj;
@end

@implementation APErrorViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustViewForiOS7];
    
    _button.hidden = YES;
    _bottomMessage.hidden = YES;
    
    if( _alertView )
    {
        [_alertView show];
    }
}

-(void)setErrorObj:(NSError *)error
{
    _errorObj = error;
    [self view];
    _mainMessage.text = _errorObj.localizedDescription;
    NSDictionary * dict = error.userInfo;
    NSString * showContinue = @"Continue"; // dict[kAPYouDontHaveToGoHomeButYouCantStayHereKey];
    if( showContinue )
    {
        [_button setTitle:showContinue forState:UIControlStateNormal];
        _button.hidden = NO;
    }
    else
    {
        _bottomMessage.hidden = NO;
        _bottomMessage.text = _errorObj.localizedRecoverySuggestion;
    }
}

-(void)dismiss
{
    [self performSegueWithIdentifier:kSegueErrorUnwind sender:self];
}
@end

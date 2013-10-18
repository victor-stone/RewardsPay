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
@property (weak, nonatomic) IBOutlet UILabel *mainMessage;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic,strong) NSError *errorObj;
@end

@implementation APErrorViewController

APLOGRELEASE

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustViewForiOS7];
    _button.layer.masksToBounds = YES;
    _button.layer.cornerRadius = 8.0;
}

-(void)setErrorObj:(NSError *)error
{
    _errorObj = error;
    [self view];
    _mainMessage.text = _errorObj.localizedDescription;
}

-(void)dismiss
{
    [self performSegueWithIdentifier:kSegueErrorUnwind sender:self];
}
@end

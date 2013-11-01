//
//  APPinViewController.m
//  ArgoPay
//
//  Created by victor on 11/1/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APPinViewController.h"

@implementation APPinViewController {
    @package
    NSUInteger _numDigits;
    NSString * _dotCharacter;
    NSUInteger _digits[4];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustViewForiOS7];
    _dotCharacter = [_maskLabel.text stringByPaddingToLength:1 withString:@"" startingAtIndex:0];
    _dotCharacter = [_dotCharacter stringByAppendingString:@" "];
    _maskLabel.text = nil;
    _doneButton.enabled = NO;
}

- (IBAction)numberButton:(UIButton *)button
{
    if( _numDigits == 4 )
        return;
    _digits[_numDigits++] = button.tag;
    _doneButton.enabled = _numDigits == 4 ? YES : NO;
    _maskLabel.text = [@"" stringByPaddingToLength:_numDigits*2
                                        withString:_dotCharacter
                                   startingAtIndex:0];
}

- (IBAction)clear:(id)sender
{
    _numDigits = 0;
    _doneButton.enabled = NO;
    _maskLabel.text = nil;
}

- (IBAction)deleteLastNumber:(id)sender
{
    if( _numDigits )
    {
        _doneButton.enabled = NO;
        --_numDigits;
        _maskLabel.text = [@"" stringByPaddingToLength:_numDigits*2
                                            withString:_dotCharacter
                                       startingAtIndex:0];
    }
}

- (NSString *)PIN
{
    return [NSString stringWithFormat:@"%d%d%d%d", _digits[0],_digits[1],_digits[2],_digits[3]];
}

@end


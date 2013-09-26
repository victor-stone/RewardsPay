//
//  APMerchantDetailViewController.m
//  ArgoPay
//
//  Created by victor on 9/22/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APMerchant.h"
#import "APStrings.h"
#import "APPopup.h"

@interface APMerchantDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *credit;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@end


@implementation APMerchantDetailCell

@end

@interface APMerchantDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UILabel *merchantPoints;
@property (weak, nonatomic) IBOutlet UILabel *streetAddr;
@property (weak, nonatomic) IBOutlet UILabel *cityState;
@property (weak, nonatomic) IBOutlet UITextView *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextView *urlAddr;
@property (weak, nonatomic) IBOutlet UINavigationBar *orangeNavBar;
@property (weak, nonatomic) IBOutlet UITableView *pointsTable;
@property (weak, nonatomic) IBOutlet UIButton *discloseButton;

@property (nonatomic,strong) APMerchant * merchant;
@end

@implementation APMerchantDetailViewController {
    bool _loaded;
    bool _showingPoints;
    NSArray * _points;
    NSArray * _actualPoints;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addBackButton:_orangeNavBar];
    _loaded = true;
    _pointsTable.alpha = 0;
    if( _merchant )
        [self commitMerchant];
    
}

-(void)commitMerchant
{
    _merchantName.text = _merchant.name;
    _merchantPoints.text = [NSString stringWithFormat:NSLocalizedString(@"%dpts","MerchantDetail"),[_merchant.credits integerValue]];
    _streetAddr.text = _merchant.address;
    _cityState.text = [NSString stringWithFormat:@"%@, %@", _merchant.city, _merchant.state];
    _phoneNumber.text = _merchant.phone;
    _urlAddr.text = [_merchant.url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
}

-(void)setMerchant:(APMerchant *)merchant
{
    _merchant = merchant;
    [self commitMerchant];
}

- (IBAction)disclose:(id)sender
{
    if( _showingPoints )
    {
        [UIView animateWithDuration:0.4 animations:^{
            _pointsTable.alpha = 0;
            _discloseButton.transform = CGAffineTransformMakeRotation(0);
        }];
        
    }
    else
    {
        if( _points )
        {
            [self expandTable];
        }
        else
        {
            [_merchant getMerchantPoints:^(NSArray * points,NSError *err) {
                if( err )
                {
                    [self showError:err];
                }
                else
                {
                    _points = points;
                    [_pointsTable reloadData];
                    [self expandTable];
                }
            }];
        }
    }
    _showingPoints = !_showingPoints;
}

-(void)expandTable
{
    [UIView animateWithDuration:0.4 animations:^{
        _pointsTable.alpha = 1.0;
        _discloseButton.transform = CGAffineTransformMakeRotation(90 * M_PI / 180.0);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_points count];
}

-(void)redeemCredit:(UIButton *)button
{
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = button.frame;
    av.frame = frame;
    av.alpha = 0;
    [av startAnimating];
    [button.superview addSubview:av];
    [UIView animateWithDuration:0.3 animations:^{
        button.alpha = 0;
        av.alpha = 1.0;
    }];
    
    APMerchantPoints * points = _points[button.tag];
    [_merchant redeemPoints:points block:^(id data, NSError *err) {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            _merchantPoints.text = [NSString stringWithFormat:NSLocalizedString(@"%dpts","MerchantDetail"),[_merchant.credits integerValue]];
            [_pointsTable reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APMerchantDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDMerchantDetail forIndexPath:indexPath];
    APMerchantPoints * points = _points[indexPath.row];
    NSInteger credits = [_merchant.credits integerValue];
    NSInteger pts = [points.points integerValue];
    if( credits >= pts )
    {
        cell.redeemButton.hidden = NO;
        cell.redeemButton.alpha = 1.0;
        cell.redeemButton.tag = indexPath.row;
        [cell.redeemButton addTarget:self action:@selector(redeemCredit:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.redeemButton.hidden = YES;
    }
    
    cell.points.text = [NSString stringWithFormat:NSLocalizedString(@"%dpts","MerchantDetailCell"), pts];
    cell.credit.text = points.value;
    return cell;
}

@end

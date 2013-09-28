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
#import "APAccount.h"

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
    NSArray * _rewards;
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
    _merchantName.text = _merchant.Name;
    NSInteger whatPoints = 200;
    _merchantPoints.text = @"200pts"; // [NSString stringWithFormat:NSLocalizedString(@"%dpts","MerchantDetail"),[_merchant.credits integerValue]];
    _streetAddr.text = _merchant.Addr1;
    _cityState.text = [NSString stringWithFormat:@"%@, %@", _merchant.City, _merchant.State];
    _phoneNumber.text = _merchant.Tel;
    _urlAddr.text = [_merchant.Website stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    [self fetchRewardPoints];
    
}

-(void)fetchRewardPoints
{
    APMerchantRewardListRequest * request = [APMerchantRewardListRequest new];
    NSString * mtoken = @"";
    NSString * mloc = @"";
    request.MToken = @"fakeToken";
    request.MLocID = @"fakeLocID";
    [request performRequest:^(NSArray *rewards, NSError *err) {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            _rewards = rewards;
            [_pointsTable reloadData];
        }
    }];
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
        if( _rewards )
        {
            [self expandTable];
        }
        else
        {
            // points haven't arrived yet, try again later
            [NSObject performBlock:^{
                [self disclose:sender];
            } afterDelay:0.6];
            return;
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
    return [_rewards count];
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
    
    APMerchantReward * reward = _rewards[button.tag];
    APMerchantRewardRedeemd *request = [APMerchantRewardRedeemd new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.RewardID = reward.RewardID;
    [request performRequest:^(APRemoteRepsonse *response, NSError *err) {
        [av removeFromSuperview];
        if( err )
        {
            [self showError:err];
        }
        else
        {
            [self fetchRewardPoints];
        }
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APMerchantDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDMerchantDetail forIndexPath:indexPath];
    APMerchantReward * points = _rewards[indexPath.row];
    NSInteger TODO_whatCredits = 999; // [_merchant.credits integerValue];
    NSInteger credits = 200;
    NSInteger pts = [points.PointsRequired integerValue];
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
    cell.credit.text = [NSString stringWithFormat:@"$%d",[points.AmountReward integerValue]];
    return cell;
}

@end

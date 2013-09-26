//
//  APRewardViewController.m
//  ArgoPay
//
//  Created by victor on 9/24/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APArgoPointsReward.h"
#import "APMerchant.h"
#import "APPopup.h"
#import "APAccount.h"

@interface APRewardsCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UIImageView *logo;
@property (weak,nonatomic) IBOutlet UILabel *merchantName;
@property (weak,nonatomic) IBOutlet UILabel *points;
@property (weak,nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak,nonatomic) IBOutlet UILabel *status;
@end

@implementation APRewardsCell
@end


@interface APRewardsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *argPoints;
@property (weak, nonatomic) IBOutlet UITableView *rewardsTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation APRewardsViewController {
    NSArray *_rewards;
}


APLOGRELEASE

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton:_navBar];
    
    APAccount *account = [APAccount sharedInstance];
    _argPoints.text = [NSString stringWithFormat:@"%d",[account.argoPoints integerValue]];
    
    APPopup * popup = nil;

    popup = [APPopup popupWithParent:self.view
                                text: NSLocalizedString(@"Contacting ArgoPay Server","popup")
                               flags:kPopupActivity];
    
    APRemoteAPI *api = [APRemoteAPI sharedInstance];
    [api getRewards:^(id data, NSError *error) {
        if( error )
        {
            [popup dismiss];
            [self showError:error];
        }
        else
        {
            _rewards = data;
            [_rewardsTable reloadData];
            [popup dismiss];
        }
    }];
}

-(void)updateReward:(APArgoPointsReward *)replacement
{
    APAccount *account = [APAccount sharedInstance];
    NSInteger argoPts = [account.argoPoints integerValue];
    _argPoints.text = [NSString stringWithFormat:@"%d",argoPts];
    @synchronized(self) {
        _rewards = [_rewards map:^id(APArgoPointsReward *obj) {
            if( [obj.key isEqual:replacement.key] )
                return replacement;
            return  obj;
        }];
        [_rewardsTable reloadData];
    }    
}

-(void)redeemReward:(UIButton *)button
{
    APArgoPointsReward * reward = _rewards[button.tag];
    [reward redeem:^(APArgoPointsReward *result, NSError *err) {
        if( err )
            [self showError:err];
        else
            [self updateReward:result];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rewards count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APArgoPointsReward * reward = _rewards[indexPath.row];
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewMerchantDetail];
    [vc setValue:reward.merchant forKey:@"merchant"];
    [self presentViewController:vc animated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APRewardsCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDReward forIndexPath:indexPath];
    APArgoPointsReward * reward = _rewards[indexPath.row];
    
    cell.merchantName.text = reward.merchant.name;
    cell.points.text = [NSString stringWithFormat:@"%d",[reward.points intValue]];
    cell.value.text = [NSString stringWithFormat:@"$%.0f", [reward.credit floatValue]];
    // TODO: delay this with network call
  //  [cell.logo setImage:reward.merchant.logoImg];
    if( reward.status == kRewardStatusSeekingRedemption )
    {
        cell.status.hidden = YES;
        cell.redeemButton.hidden = YES;
        cell.activity.hidden = NO;
        [cell.activity startAnimating];
    }
    else if( reward.status == kRewardStatusRedeemable )
    {
        cell.status.hidden = YES;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];
        cell.redeemButton.hidden = NO;
        cell.redeemButton.tag = indexPath.row;
        [cell.redeemButton addTarget:self action:@selector(redeemReward:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if( reward.status == kRewardStatusReadyToUse )
    {
        cell.status.hidden = NO;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];
        cell.redeemButton.hidden = YES;
    }
    else 
    {
        cell.redeemButton.hidden = YES;
        cell.status.hidden = NO;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];
    }
    return cell;
}

@end



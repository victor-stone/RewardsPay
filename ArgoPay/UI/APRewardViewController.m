//
//  APRewardViewController.m
//  ArgoPay
//
//  Created by victor on 9/24/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APArgoPointsReward.h"
#import "APPopup.h"
#import "APAccount.h"
#import "APRemoteStrings.h"

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
    NSString *_currentSort;
}


APLOGRELEASE

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton:_navBar];
    
    APAccount *account = [APAccount currentAccount];
    _argPoints.text = [NSString stringWithFormat:@"%d",[account.argoPoints integerValue]];
    _currentSort = kRemoteValueSortByNewest;
    [self fetchRewards:YES];
}

-(void)fetchRewards:(BOOL)withUI;
{
    APPopup * popup = nil;
    
    if( withUI )
        popup = [APPopup withNetActivity:self.view];
    
    APRequestRewards *request = [[APRequestRewards alloc] init];
    
    request.AToken = @"FakeToken"; // TODO put real data here
    request.Distance = @(20.0);
    request.Lat = @(343.0032);
    request.Long = @(-893.32099);
    request.SortBy = _currentSort;
    [request performRequest:^(id data, NSError *err) {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            _rewards = data;
            [_rewardsTable reloadData];
            [popup dismiss];
        }
    }];
}

-(void)redeemReward:(UIButton *)button
{
    APArgoPointsReward * reward = _rewards[button.tag];
    APActivateReward *request = [APActivateReward new];
    request.AToken = @"Er, Yea, OK";
    request.RewardID = reward.RewardID;
    [request performRequest:^(APRemoteRepsonse *response, NSError *err) {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            if( response.UserMessage.length > 0 )
            {
                [APPopup msgWithParent:self.view text:response.UserMessage];
                [self fetchRewards:NO];
            }
        }
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
    [vc setValue:reward forKey:@"merchant"];
    [self presentViewController:vc animated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APRewardsCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDReward forIndexPath:indexPath];
    APArgoPointsReward * reward = _rewards[indexPath.row];
    
    cell.merchantName.text = reward.Name;
    cell.points.text = [NSString stringWithFormat:@"%d",[reward.PointsRequired intValue]];
    cell.value.text = [NSString stringWithFormat:@"$%.0f", [reward.AmountReward floatValue]];

    [cell.logo setImageWithURL:[NSURL URLWithString:reward.ImageURL] placeholderImage:[UIImage imageNamed:@"appIcon"]];

    if( [reward.Selected boolValue] == NO )
    {
        cell.status.hidden = YES;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];
        cell.redeemButton.hidden = NO;
        cell.redeemButton.tag = indexPath.row;
        [cell.redeemButton addTarget:self action:@selector(redeemReward:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.status.hidden = NO;
        cell.redeemButton.hidden = YES;
    }
    return cell;
}

@end



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
#import "APLocation.h"

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
    APPopup * _popup;
}


APLOGRELEASE

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    _argPoints.text = @"";
    _currentSort = kRemoteValueSortByNewest;
    [self fetchRewards:YES];
}

-(void)fetchRewards:(BOOL)withUI;
{
    if( withUI && !_popup )
        _popup = [APPopup withNetActivity:self.view];

    APAccount *account = [APAccount currentAccount];
    
    APRequestStatementSummary *summaryReq = [APRequestStatementSummary new];
    summaryReq.AToken = account.AToken;
    [summaryReq performRequest:^(APAccountSummary *summary) {
        _argPoints.text = [NSString stringWithFormat:@"%d",[summary.ArgoPoints integerValue]];
    }];
    
    APRequestGetAvailableRewards *request = [APRequestGetAvailableRewards new];
    request.AToken = account.AToken;
    request.Distance = @(20.0);
    request.SortBy = _currentSort;
    [[APLocation sharedInstance] currentLocation:^(CLLocationCoordinate2D loc) {
        request.Lat = @(loc.latitude);
        request.Long = @(loc.longitude);
        [request performRequest:^(id data) {
            _rewards = data;
            [_rewardsTable reloadData];
            [_popup dismiss];
            _popup = nil;
        }];
    }];
}

-(void)redeemReward:(UIButton *)button
{
    APArgoPointsReward * reward = _rewards[button.tag];
    [reward setFetchingON];
    NSArray *ip = @[[NSIndexPath indexPathForRow:button.tag inSection:0]];
    [_rewardsTable reloadRowsAtIndexPaths:ip
                         withRowAnimation:UITableViewRowAnimationFade];
    
    APRequestActivateReward *request = [APRequestActivateReward new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.RewardID = reward.RewardID;
    [request performRequest:^(APRemoteRepsonse *response) {
        if( response.UserMessage.length > 0 )
        {
            [reward setFetchingOFF];
            reward.Selectable = kRemoteValueNO;
            [_rewardsTable reloadRowsAtIndexPaths:ip
                                 withRowAnimation:UITableViewRowAnimationFade];
            
            [APPopup msgWithParent:self.view text:response.UserMessage];
        }
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rewards count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueRewardsToMerchantDetail] )
    {
        APArgoPointsReward * reward = _rewards[[_rewardsTable indexPathForSelectedRow].row];
        UIViewController *vc = segue.destinationViewController;
        [vc setValue:reward.MLocID forKey:@"MLocID"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APRewardsCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDReward forIndexPath:indexPath];
    APArgoPointsReward * reward = _rewards[indexPath.row];
    
    cell.merchantName.text = reward.Name;
    cell.points.text = [NSString stringWithFormat:@"%d",[reward.PointsRequired intValue]];
    cell.value.text = [NSString stringWithFormat:@"$%.0f", [reward.AmountReward floatValue]];

    [cell.logo setImageWithURL:[NSURL URLWithString:reward.ImageURL] placeholderImage:[UIImage imageNamed:kImageLogo]];

    if( [reward isFetching] == YES )
    {
        cell.status.hidden = YES;
        cell.activity.hidden = NO;
        [cell.redeemButton setTitle:@"" forState:UIControlStateNormal];
        [cell.activity startAnimating];
    }
    else if( [reward.Selectable isRemoteYES] )
    {
        cell.activity.hidden = YES;
        cell.redeemButton.hidden = NO;
        cell.redeemButton.tag = indexPath.row;
        [cell.redeemButton setTitle:NSLocalizedString(@"Redeem","Reward listing") forState:UIControlStateNormal];
        [cell.redeemButton addTarget:self action:@selector(redeemReward:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.activity.hidden = YES;
        cell.status.hidden = NO;
        cell.redeemButton.hidden = YES;
    }
    return cell;
}

@end



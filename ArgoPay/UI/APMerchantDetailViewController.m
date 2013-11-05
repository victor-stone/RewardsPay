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
#import "APArgoPointsReward.h"
#import "VSTabNavigatorViewController.h"
#import "APMerchantMap.h"


@interface APMerchantDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *credit;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@end


@implementation APMerchantDetailCell 
@end

@interface APMerchantDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UILabel *merchantPoints;
@property (weak, nonatomic) IBOutlet UILabel *streetAddr;
@property (weak, nonatomic) IBOutlet UILabel *cityState;
@property (weak, nonatomic) IBOutlet UIButton *phone;

@property (weak, nonatomic) IBOutlet UIButton *urlAddr;

@property (weak, nonatomic) IBOutlet UITableView *pointsTable;
@property (weak, nonatomic) IBOutlet UIButton *discloseButton;

@property (nonatomic,strong) NSNumber * MLocID;
@end

@implementation APMerchantDetailViewController {
    bool _showingRewards;
    NSArray * _rewards;
    APMerchant *_merchant;
    __weak  APMerchantDetailMapEmbedding * _map;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];

    _pointsTable.alpha = 0;
    _merchantName.text = nil;
    _merchantPoints.text = nil;
    _streetAddr.text = nil;
    _cityState.text = nil;
    [_phone setTitle:@"" forState:UIControlStateNormal];
    [_urlAddr setTitle:@"" forState:UIControlStateNormal];
}

-(void)setMLocID:(NSNumber *)MLocID
{
    _MLocID = MLocID;

    // problem: this is not block the tab navigator at the bottom
    // because we are not in the hierarchy yet.
    APPopup * popup = nil;
    
    if( !_showingRewards )
        popup = [APPopup withNetActivity:self.view]; // forces a view load

    APRequestMerchantLocationDetail *request = [APRequestMerchantLocationDetail new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.MLocID = _MLocID;
    [request performRequest:^(APMerchantDetail *merchantDetail) {
        [_map performSelectorOnMainThread:@selector(setMerchant:) withObject:merchantDetail waitUntilDone:NO];
        _merchantName.text = merchantDetail.Name;
        _merchantPoints.text = [NSString stringWithFormat:@"%dpts",[merchantDetail.ConsumerPoints integerValue] ];
        _streetAddr.text = merchantDetail.Addr1;
        _cityState.text = [NSString stringWithFormat:@"%@, %@", merchantDetail.City, merchantDetail.State];
        if( merchantDetail.Tel.length && ![merchantDetail.Tel isEqualToString:@"None"] )
            [_phone setTitle:merchantDetail.Tel forState:UIControlStateNormal];
        if( merchantDetail.Website && ![merchantDetail.Website isEqualToString:@"None"] )
            [_urlAddr setTitle:[merchantDetail.Website stringByReplacingOccurrencesOfString:@"http://" withString:@""] forState:UIControlStateNormal];
        _rewards = merchantDetail.Rewards;
        if( _showingRewards )
        {
            [_pointsTable reloadSections:[NSIndexSet indexSetWithIndex:0]
                        withRowAnimation:UITableViewRowAnimationMiddle];
        }
        else
        {
            [_pointsTable reloadData];
        }
        [popup dismiss];
    }];
}
- (IBAction)phoneTap:(UIButton *)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Phone", @"merchantdetail")
                                                     message:@"Call merchant?"
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"merchantdetail")
                                           otherButtonTitles:NSLocalizedString(@"OK", @"merchantdetail"), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 1 )
    {
        NSString * urlStr = [NSString stringWithFormat:@"tel:%@", _phone.titleLabel.text];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
}

- (IBAction)websiteTap:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",sender.titleLabel.text]]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueEmbedMerchantMap] )
        _map = segue.destinationViewController;
}

- (IBAction)disclose:(id)sender
{
    if( _showingRewards )
    {
        [UIView animateWithDuration:0.4 animations:^{
            _pointsTable.alpha = 0;
            _discloseButton.transform = CGAffineTransformMakeRotation(0);
        }];
        
    }
    else
    {
        [self expandTable];
    }
    _showingRewards = !_showingRewards;
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

-(IBAction)redeemCredit:(UIButton *)button
{
    APArgoPointsReward *reward  = _rewards[button.tag];
    [reward setFetchingON];
    [_pointsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]
                        withRowAnimation:UITableViewRowAnimationNone];
    
    APRequestActivateReward *request = [APRequestActivateReward new];
    APAccount               *account = [APAccount currentAccount];
    
    request.AToken   = account.AToken;
    request.RewardID = reward.RewardID;

    [request performRequest:^(APRemoteRepsonse *response) {
        // sigh, for now just refresh the whole page
        self.MLocID = _MLocID;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellID = kCellIDMerchantDetail;

    APArgoPointsReward * reward = _rewards[indexPath.row];
    
    if( [reward isFetching] )
    {
        cellID = [cellID stringByAppendingString:@"-redeeming"];
    }
    else if( [reward.Selectable isRemoteYES] )
    {
        cellID = [cellID stringByAppendingString:@"-selectable"];
    }
    
    APMerchantDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if( cell.activity )
        [cell.activity startAnimating];
    
    if( cell.redeemButton )
       [cell.redeemButton addTarget:self action:@selector(redeemCredit:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.points.text = [NSString stringWithFormat:NSLocalizedString(@"%dpts","MerchantDetailCell"), [reward.AmountReward integerValue]];
    cell.credit.text = [NSString stringWithFormat:@"$%d credit",[reward.PointsRequired integerValue]];
    return cell;
}

@end

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
#import <GoogleMaps/GoogleMaps.h>
#import "APArgoPointsReward.h"

@interface APMerchantDetailMapEmbedding : UIViewController

@end

@implementation APMerchantDetailMapEmbedding {
    GMSMapView *mapView_;
}


- (void)loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
}
@end

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

@property (nonatomic,strong) NSString * MLocID;
@end

@implementation APMerchantDetailViewController {
    bool _showingRewards;
    NSArray * _rewards;
}

APLOGRELEASE

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self argoPayIze];
	[self addBackButton:_orangeNavBar];
    _pointsTable.alpha = 0;
    _merchantName.text = nil;
    _merchantPoints.text = nil;
    _streetAddr.text = nil;
    _cityState.text = nil;
    _phoneNumber.text = nil;
    _urlAddr.text = nil;
    
    if( _MLocID )
        self.MLocID = _MLocID;
    
}

-(void)setMLocID:(NSString *)MLocID
{
    _MLocID = MLocID;
    if( _merchantName )
    {
        APRequestMerchantLocationDetail *request = [APRequestMerchantLocationDetail new];
        APAccount *account = [APAccount currentAccount];
        request.AToken = account.AToken;
        request.MLocID = _MLocID;
        [request performRequest:^(APMerchantDetail *merchantDetail, NSError *err) {
            if(err)
            {
                [self showError:err];
            }
            else
            {
                _merchantName.text = merchantDetail.Name;
                _merchantPoints.text = [NSString stringWithFormat:@"%dpts",[merchantDetail.ConsumerPoints integerValue] ];
                _streetAddr.text = merchantDetail.Addr1;
                _cityState.text = [NSString stringWithFormat:@"%@, %@", merchantDetail.City, merchantDetail.State];
                _phoneNumber.text = merchantDetail.Tel;
                _urlAddr.text = [merchantDetail.Website stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                _rewards = merchantDetail.Rewards;
                [_pointsTable reloadData];
            }
        }];
        
    }
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
    
    APArgoPointsReward * reward = _rewards[button.tag];
    APRequestActivateReward *request = [APRequestActivateReward new];    
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
            // sigh, for now just refresh the whole page
            self.MLocID = _MLocID;
        }
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APMerchantDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDMerchantDetail forIndexPath:indexPath];
    APArgoPointsReward * reward = _rewards[indexPath.row];
    if( [reward.Selectable isRemoteYES] )
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
    
    cell.points.text = [NSString stringWithFormat:NSLocalizedString(@"%dpts","MerchantDetailCell"), [reward.AmountReward integerValue]];
    cell.credit.text = [NSString stringWithFormat:@"$%d credit",[reward.PointsRequired integerValue]];
    return cell;
}

@end

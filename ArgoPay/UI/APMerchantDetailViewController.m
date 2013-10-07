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
#import "APMerchantMap.h"

@implementation APMerchantDetailMapEmbedding {
    GMSMapView *mapView_;
}

- (void)loadView
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees mlat  = [defaults doubleForKey:kSettingUserLastLat];
    CLLocationDegrees mlong = [defaults doubleForKey:kSettingUserLastLong];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mlat
                                                            longitude:mlong
                                                                 zoom:13];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = mapView_;
    if( _merchant )
        [self setMerchant:_merchant];
}

-(void)setMerchant:(APMerchant *)merchant
{
    _merchant = merchant;
    if( mapView_ )
    {
        CLLocationDegrees mlat  = [_merchant.Lat doubleValue];
        CLLocationDegrees mlong = [_merchant.Long doubleValue];
        APLOG(kDebugLocation, @"Creating map for %@ at %.3f, %.3f", _merchant.Name, mlat, mlong);

        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(mlat,mlong);
        [mapView_ moveCamera:[GMSCameraUpdate setTarget:coord]];
        // Creates a marker in the center of the map.
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = coord;
        marker.title = _merchant.Name;
        marker.snippet = _merchant.Description;
        marker.map = mapView_;
        
        mapView_.myLocationEnabled = YES;
        mapView_.settings.myLocationButton = YES;
    }
}
@end

@interface APMerchantDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *credit;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
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
    APMerchant *_merchant;
    __weak  APMerchantDetailMapEmbedding * _map;
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
                [_map performSelectorOnMainThread:@selector(setMerchant:) withObject:merchantDetail waitUntilDone:NO];
                _merchantName.text = merchantDetail.Name;
                _merchantPoints.text = [NSString stringWithFormat:@"%dpts",[merchantDetail.ConsumerPoints integerValue] ];
                _streetAddr.text = merchantDetail.Addr1;
                _cityState.text = [NSString stringWithFormat:@"%@, %@", merchantDetail.City, merchantDetail.State];
                _phoneNumber.text = merchantDetail.Tel;
                _urlAddr.text = [merchantDetail.Website stringByReplacingOccurrencesOfString:@"http://" withString:@""];
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
            }
        }];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

-(void)redeemCredit:(UIButton *)button
{
    APArgoPointsReward      *reward  = _rewards[button.tag];
    [reward setFetchingON];
    [_pointsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]
                        withRowAnimation:UITableViewRowAnimationNone];
    
    APRequestActivateReward *request = [APRequestActivateReward new];
    APAccount               *account = [APAccount currentAccount];
    
    request.AToken   = account.AToken;
    request.RewardID = reward.RewardID;
    
    [request performRequest:^(APRemoteRepsonse *response, NSError *err) {
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
    cell.activity.hidden = YES;
    
    if( [reward isFetching] )
    {
        cell.redeemButton.hidden = NO;
        cell.activity.hidden = NO;
        [cell.activity startAnimating];
        [cell.redeemButton setTitle:@"" forState:UIControlStateNormal];
    }
    else if( [reward.Selectable isRemoteYES] )
    {
        cell.redeemButton.hidden = NO;
        cell.redeemButton.tag = indexPath.row;
        [cell.redeemButton setTitle:NSLocalizedString(@"Redeem", @"merchant detail reward") forState:UIControlStateNormal];
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

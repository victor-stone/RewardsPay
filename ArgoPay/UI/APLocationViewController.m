//
//  APLocationViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import <GoogleMaps/GoogleMaps.h>
#import "APMerchant.h"
#import "APRemoteStrings.h"
#import <CoreLocation/CoreLocation.h>
#import "APLocation.h"
#import "APPopup.h"

#define KM_TO_MILES_MULTIPLIER 0.621371192

@interface APLocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@end

@implementation APLocationCell
@end

@interface APLocationListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *locationsTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;
@end

@implementation APLocationListViewController {
    NSArray *_locations;
    CLLocation *_userLocation;
    BOOL _viewAsKM;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addHomeButton:_argoNavBar];

    UIBarButtonItem *bbi = [self barButtonForImage:kImageMapView
                                             title:nil
                                             block:^(APLocationListViewController *me, id sender)
    {
        // flip to mapview
    }];
    
    [self addRightButton:_argoNavBar button:bbi];
    [self fetchLocations];
    _viewAsKM = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingViewAsKilometer];
    [self registerForBroadcast:kNotifyUserSettingChanged block:^(APLocationListViewController *me, NSDictionary *settings)
     {
         for( NSString *key in settings )
         {
             if( [key isEqualToString:kSettingViewAsKilometer] )
             {
                 BOOL newSetting = [settings[key] boolValue];
                 if( newSetting != me->_viewAsKM )
                 {
                     _viewAsKM = newSetting;
                     [NSObject performBlock:^{
                         [me->_locationsTable reloadData];
                     } afterDelay:0.1];
                 }
             }
         }
     }];
}

-(void)fetchLocations
{
    APPopup *popup = [APPopup withNetActivity:self.view];
    
    APRequestMerchantLocationSearch * request = [APRequestMerchantLocationSearch new];
    request.SortBy = kRemoteValueDistance;
    request.Distance = @(20);
    request.CategoryID = @(0);
    request.Limit = @(200);
    [[APLocation sharedInstance] currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [popup dismiss];
            [self showError:error];
            return YES; // right?
        }
        else
        {
            _userLocation = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
            request.Long = @(loc.longitude);
            request.Lat = @(loc.latitude);
            [request performRequest:^(NSArray * data, NSError *err) {
                [popup dismiss];
                if( err )
                {
                    [self showError:err];
                }
                else
                {
                    _locations = data;
                    [_locationsTable reloadData];
                }
            }];
        }
        return NO;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_locations count] * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( (indexPath.row & 1) == 0 )
    {
        return [tableView dequeueReusableCellWithIdentifier:@"kCellIDLocationSpacer" forIndexPath:indexPath];
    }
    APLocationCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDLocation forIndexPath:indexPath];
    cell.contentView.layer.cornerRadius = 5.0;
    
    APMerchant * merchant = _locations[indexPath.row/2];
    CLLocationDegrees bizlat = [merchant.Lat doubleValue];
    CLLocationDegrees bizlong = [merchant.Long doubleValue];
    CLLocation *bizLocation = [[CLLocation alloc] initWithLatitude:bizlat longitude:bizlong];
    CLLocationDistance distance =  [_userLocation distanceFromLocation:bizLocation] / 1000;
    APLOG(kDebugLocation, @"Biz location: {%f,%f} distance: %.1fkm", bizlat, bizlong, distance);
    NSString *units = nil;
    if(  _viewAsKM )
    {
        units = @"km";
    }
    else
    {
        distance *= KM_TO_MILES_MULTIPLIER;
        units = @"ml";
    }
    cell.distance.text = [NSString stringWithFormat:@"%.1f%@",distance,units];
    cell.businessName.text = merchant.Name;
    cell.category.text = merchant.Category;
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 15.0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( (indexPath.row & 1) == 0 )
        return;
    
    APMerchant * merchant = _locations[indexPath.row/2];
    UIViewController *vc = [self presentVC:kViewMerchantDetail animated:YES completion:nil];
    [vc setValue:merchant.MLocID forKey:@"MLocID"];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( (indexPath.row & 1) == 0 )
        return 12;
    return tableView.rowHeight;
    
}
@end

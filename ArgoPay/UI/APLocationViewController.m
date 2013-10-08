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
}

-(void)fetchLocations
{
    APRequestMerchantLocationSearch * request = [APRequestMerchantLocationSearch new];
    request.SortBy = kRemoteValueDistance;
    request.Distance = @(20);
    [[APLocation sharedInstance] currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [self showError:error];
            return YES; // right?
        }
        else
        {
            _userLocation = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
            request.Long = @(loc.longitude);
            request.Lat = @(loc.latitude);
            [request performRequest:^(NSArray * data, NSError *err) {
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
    return [_locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APLocationCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDLocation forIndexPath:indexPath];
    APMerchant * merchant = _locations[indexPath.row];
    CLLocationDegrees bizlat = [merchant.Lat doubleValue];
    CLLocationDegrees bizlong = [merchant.Long doubleValue];
    CLLocation *bizLocation = [[CLLocation alloc] initWithLatitude:bizlat longitude:bizlong];
    CLLocationDistance distance = [_userLocation distanceFromLocation:bizLocation] / 1000;
    APLOG(kDebugLocation, @"Biz location: {%f,%f} distance: %.1fkm", bizlat, bizlong, distance);
    cell.distance.text = [NSString stringWithFormat:@"%.1fkm",distance];
    cell.businessName.text = merchant.Name;
    cell.category.text = merchant.Category;
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 15.0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APMerchant * merchant = _locations[indexPath.row];
    UIViewController *vc = [self presentVC:kViewMerchantDetail animated:YES completion:nil];
    [vc setValue:merchant.MLocID forKey:@"MLocID"];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

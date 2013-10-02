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
    [[APLocation sharedInstance] currentLocation:^{
#warning Need to work out what to do when location fails.
    } gotLocation:^(CLLocationCoordinate2D loc) {
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
    cell.businessName.text = merchant.Name;
    cell.category.text = merchant.Category;
    return cell;
}

@end

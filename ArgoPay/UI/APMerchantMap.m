//
//  APMerchantMap.m
//  ArgoPay
//
//  Created by victor on 10/7/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "APMerchantMap.h"
#import "APMerchant.h"
#import "APStrings.h"

@interface APMerchantDetailMapEmbedding () <GMSMapViewDelegate>

@end

@implementation APMerchantDetailMapEmbedding {
    GMSMapView *mapView_;
}

APLOGRELEASE

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
    
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.delegate = self;
}

-(void)setMerchant:(APMerchant *)merchant
{
    [self setMerchants:@[merchant]];
    [self setHomeLocationToMerchant:merchant];
}

-(void)setMerchants:(NSArray *)merchants
{
    _merchants = merchants;
    [self view];
    for( APMerchant *merchant in merchants)
    {
        [self markerForMerchant:merchant];
    }
}

-(APMerchant *)merchant
{
    return _merchants[0];
}

-(void)setHomeLocationToMerchant:(APMerchant *)merchant
{
    CLLocationDegrees mlat  = [merchant.Lat doubleValue];
    CLLocationDegrees mlong = [merchant.Long doubleValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(mlat,mlong);
    self.homeLocation = coord;
}

-(void)setHomeLocation:(CLLocationCoordinate2D)coord
{
    [self view]; // force viewDidLoad
    APLOG(kDebugLocation, @"Setting camera to home at %.3f, %.3f", coord.latitude, coord.longitude);
    [mapView_ moveCamera:[GMSCameraUpdate setTarget:coord]];
}

-(GMSMarker *)markerForMerchant:(APMerchant *)merchant
{
    CLLocationDegrees mlat  = [merchant.Lat doubleValue];
    CLLocationDegrees mlong = [merchant.Long doubleValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(mlat,mlong);
    APLOG(kDebugLocation, @"Creating pin for %@ at %.3f, %.3f", merchant.Name, mlat, mlong);
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coord;
    marker.title = merchant.Name;
    marker.snippet = NSLocalizedString(@"Tap here for directions", @"merchantMap");
    marker.map = mapView_;
    return marker;
}

- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    APMerchant * merchant = [_merchants match:^BOOL(APMerchant *merchant) {
        return [merchant.Name isEqualToString:marker.title];
    }];
    NSString * query = [NSString stringWithFormat:@"?daddr=%@,%@,%@,%@,%@",
                        merchant.Name, merchant.Addr1, merchant.City, merchant.State, merchant.Zip];
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    BOOL userSetting = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingUserUseGoogleMaps];
    BOOL hasGoogleMaps = userSetting && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
    NSString * app;
    if( hasGoogleMaps )
    {
        app = @"comgooglemaps://";
    }
    else
    {
        app = @"http://maps.apple.com/";
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",app,query]]];
    
}
@end


@implementation APMerchantMap {
    __weak APMerchantDetailMapEmbedding * _map;
}

-(void)setMerchants:(NSArray *)merchants
{
    _merchants = merchants;
    [self view];
    _map.merchants = _merchants;
}

-(void)setHomeLocation:(CLLocationCoordinate2D)homeLocation
{
    _homeLocation = homeLocation;
    [self view];
    _map.homeLocation = _homeLocation;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueNearyByMapEmbedding] )
    {
        _map = segue.destinationViewController;
    }
}

@end

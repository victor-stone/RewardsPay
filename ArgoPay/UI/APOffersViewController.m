//
//  APOffersViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APOffer.h"
#import "APRemoteStrings.h"
#import "APAccount.h"
#import "APPopup.h"
#import <GoogleMaps/GoogleMaps.h>
#import "APLocation.h"

@interface APOfferDetailsMapEmbedding : UIViewController
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic,strong) NSString *pinTitle;
@property (nonatomic,strong) NSString *pinSnippet;
@end

@implementation APOfferDetailsMapEmbedding

- (void)loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_location.latitude
                                                            longitude:_location.longitude
                                                                 zoom:13];
    GMSMapView *mapView;
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    
    self.view = mapView;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position   = _location;
    marker.title      = _pinTitle;
    marker.snippet    = _pinSnippet;
    marker.map        = mapView;
}

@end

@interface APOffersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *offerDescription;
@property (weak, nonatomic) IBOutlet UILabel *expiration;
@end

@implementation APOffersCell

@end

@interface APOfferDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *merchantName;
@property (weak, nonatomic) IBOutlet UILabel *expiration;
@property (weak, nonatomic) IBOutlet UILabel *offerName;
@property (weak, nonatomic) IBOutlet UITextView *offerDetail;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;
@property (nonatomic,strong) APOffer *offer;
@end

@implementation APOfferDetailViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addBackButton:_argoNavBar];
    if( _offer )
        self.offer = _offer;
}

-(void)setOffer:(APOffer *)offer
{
    _offer = offer;
    [_logo setImageWithURL:[NSURL URLWithString:offer.ImageURL]];
    _merchantName.text = offer.Name;
    _offerName.text = offer.Description;
    _offerDetail.text = offer.LongDescription;
    _expiration.text = [NSString stringWithFormat:NSLocalizedString(@"Expires: %@", @"offer detail"),[offer formatDateField:@"DateTo"]];
}
@end


@interface APOffersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
                                                    UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *offersTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;
@property (nonatomic,strong) NSArray * offers;
@end

@implementation APOffersViewController {
    NSArray * _sortNames;
    NSArray * _sortTypes;
    UIActionSheet *_actionSheet;
    NSUInteger _numberOfButtonsShowing;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addHomeButton:_argoNavBar];
    [self addLoginButton:_argoNavBar];
    UIBarButtonItem * bbi = [self barButtonForImage:kImageSort
                                              title:nil
                                              block:^(APOffersViewController *me, id button) {
                                                  [me changeFilter:button];
                                              }];
    [self addRightButton:_argoNavBar button:bbi];
    
    _sortNames = @[ NSLocalizedString(@"Newest", "Offer sort type"),
                    NSLocalizedString(@"Expiring Soon", "Offer sort type"),
                    NSLocalizedString(@"Ready to use", "Offer sort type"),
                    NSLocalizedString(@"Available", "Offer sort type") /*,
                    NSLocalizedString(@"Recommended for You", "Offer sort type") */];
    
    _sortTypes = @[ kRemoteValueSortByNewest,
                    kRemoteValueSortByExpiringSoon,
                    kRemoteValueSortByReadyToUse,
                    kRemoteValueSortByAvailableToSelect
                    ];
    
    if( !_offers )
    {
        self.view.alpha = 0.0;
        [self fetchOffers:kRemoteValueSortByNewest];
        self.view.alpha = 1.0;
    }
}

-(void)fetchOffers:(NSString *)sort
{
    APPopup *popup = [APPopup withNetActivity:self.view];
    APRequestGetAvailableOffers *request = [APRequestGetAvailableOffers new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.Distance = @(20.0);
    request.SortBy = sort;

    [[APLocation sharedInstance] currentLocation:^{
        //
    } gotLocation:^(CLLocationCoordinate2D loc) {
        request.Lat = @(loc.latitude);
        request.Long = @(loc.longitude);
        [request performRequest:^(id data, NSError *err) {
            [popup dismiss];
            if( err )
            {
                [self showError:err];
            }
            else
            {
                _offers = data;
                [_offersTable reloadData];
            }
        }];
    }];
}

- (void)changeFilter:(id)sender
{
    if( [[APAccount currentAccount] isLoggedIn] )
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Order", "Offer sort")
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:_sortNames[0],_sortNames[1],_sortNames[2],_sortNames[3],nil];
        _numberOfButtonsShowing = 4;
    }
    else
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Order", "Offer sort")
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:_sortNames[0],_sortNames[1],nil];
        _numberOfButtonsShowing = 2;
    }
    
    [_actionSheet showInView:self.view.superview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_offers count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APAccount *account = [APAccount currentAccount];
    if( account.isLoggedIn )
    {
        UIViewController *vc = [self presentVC:kViewOfferDetail animated:YES completion:nil];
        APOffer * offer = _offers[indexPath.row];
        [vc setValue:offer forKey:@"offer"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APOffersCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDOffer forIndexPath:indexPath];
    APOffer * offer = _offers[indexPath.row];
    cell.businessName.text = offer.Name;
    cell.offerDescription.text = offer.Description;
    cell.expiration.text = [NSString stringWithFormat:NSLocalizedString(@"Expires in %u days","OfferListingCell"),[offer.DaysToUse integerValue]];
    cell.accessoryType = [offer.Selected isRemoteYES] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex < _numberOfButtonsShowing )
    {
        [self fetchOffers:_sortTypes[buttonIndex]];
    }
    [_actionSheet dismissWithClickedButtonIndex:5 animated:YES];
}

@end

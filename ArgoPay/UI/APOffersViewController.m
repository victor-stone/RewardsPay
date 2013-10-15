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
#import "APMerchantMap.h"


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

@implementation APOfferDetailViewController {
    __weak  APMerchantDetailMapEmbedding * _map;    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if( _offer )
        self.offer = _offer;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueEmbedOfferMap] )
    {
        _map = segue.destinationViewController;
        if( _offer )
            _map.merchant = _offer;
    }
}


-(void)setOffer:(APOffer *)offer
{
    _offer = offer;
    if( _map )
        _map.merchant = offer;
    if( _logo )
    {
        [_logo setImageWithURL:[NSURL URLWithString:offer.ImageURL] placeholderImage:[UIImage imageNamed:kImageOffers]];
        _merchantName.text = offer.Name;
        _offerName.text = offer.Description;
        _offerDetail.text = offer.LongDescription;
        _expiration.text = [NSString stringWithFormat:NSLocalizedString(@"Expires: %@", @"offer detail"),[offer formatDateField:@"DateTo"]];
    }
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
    APPopup * _popup;
    APOffer * _selectedOffer;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
#warning Add Home Button here

    UIBarButtonItem * bbi = [self barButtonForImage:kImageSort
                                              title:nil
                                              block:^(APOffersViewController *me, id button) {
                                                  [me changeFilter:button];
                                              }];
    self.navigationItem.rightBarButtonItems = @[bbi];
    
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
    
    [self registerForBroadcast:kNotifySegue
                         block:^(APOffersViewController *me, UIStoryboardSegue *segue)
     {
         [me prepareForSegue:segue sender:nil];
     }];
    
    _popup = [APPopup withNetActivity:self.view];
    
    if( !_offers )
    {
        self.view.alpha = 0.0;
        [self fetchOffers:kRemoteValueSortByNewest];
        self.view.alpha = 1.0;
    }
}

-(void)fetchOffers:(NSString *)sort
{
    if( !_popup )
        _popup = [APPopup withNetActivity:self.view];
    
    APRequestGetAvailableOffers *request = [APRequestGetAvailableOffers new];
    APAccount *account = [APAccount currentAccount];
    request.AToken = account.AToken;
    request.Distance = @(20.0);
    request.SortBy = sort;

    [[APLocation sharedInstance] currentLocation:^BOOL(CLLocationCoordinate2D loc, APError *error) {
        if( error )
        {
            [_popup dismiss];
            _popup = nil;
            [self showError:error];
            return YES;
        }
        else
        {
            request.Lat = @(loc.latitude);
            request.Long = @(loc.longitude);
            [request performRequest:^(id data, NSError *err) {
                [_popup dismiss];
                _popup = nil;
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
        }
        return NO;
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
#warning Action sheet is being clipped, move to rootView
    [_actionSheet showInView:self.view.superview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_offers count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:kSegueOffersToOfferDetail] )
    {
        UIViewController * vc = segue.destinationViewController;
        NSIndexPath * indexPath = [_offersTable indexPathForSelectedRow];
        [vc setValue:_offers[indexPath.row] forKey:@"offer"];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning Move this to prepareForSegue
    /*
    APAccount *account = [APAccount currentAccount];
    if( account.isLoggedIn )
    {
        void (^showDialog)(APOffer * offer) = ^(APOffer * offer)
        {
            _selectedOffer = offer;
            [self performSegueWithIdentifier:kSegueOffersToOfferDetail sender:self];
        };
        
        APOffer * offer = _offers[indexPath.row];
        if( [offer.Selected isRemoteYES] == NO )
        {
            APPopup *popup = [APPopup withNetActivity:self.view];
            APRequestActivateOffer *request = [APRequestActivateOffer new];
            APAccount * account = [APAccount currentAccount];
            request.AToken = account.AToken;
            request.OfferID = offer.OfferID;
            [request performRequest:^(APRemoteRepsonse *response, NSError *err) {
                [popup dismiss];
                if( err )
                {
                    [self showError:err];
                }
                else
                {
                    [NSObject performBlock:^{
                        offer.Selected = kRemoteValueYES;
                        [tableView reloadRowsAtIndexPaths:@[indexPath]
                                         withRowAnimation:UITableViewRowAnimationNone];
                        showDialog(offer);
                    } afterDelay:0.1];
                }
            }];
        }
        else
        {
            showDialog(offer);
        }
        
    }
     */
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
    [cell.imageView setImageWithURL:[NSURL URLWithString:offer.ImageURL]];
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

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

@interface APOffersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *businessName;
@property (weak, nonatomic) IBOutlet UILabel *offerDescription;
@property (weak, nonatomic) IBOutlet UILabel *expiration;
@end

@implementation APOffersCell

@end

@interface APOfferDetailViewController : UIViewController
@property (nonatomic,strong) APOffer *offer;
@end

@implementation APOfferDetailViewController

@end


@interface APOffersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,
                                                    UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *filterTypeName;

@property (weak, nonatomic) IBOutlet UITableView *offersTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;
@end

@implementation APOffersViewController {
    NSArray * _offers;
    NSArray * _sortNames;
    NSArray * _sortTypes;
    UIActionSheet *_actionSheet;
}

APLOGRELEASE

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self addHomeButton:_argoNavBar];
    _sortNames = @[ NSLocalizedString(@"Newest", "Offer sort type"),
                    NSLocalizedString(@"Ready to use", "Offer sort type"),
                    NSLocalizedString(@"Available", "Offer sort type"),
                    NSLocalizedString(@"Expiring Soon", "Offer sort type") /*,
                    NSLocalizedString(@"Recommended for You", "Offer sort type") */];
    
    _sortTypes = @[ kRemoteValueSortByNewest,
                    kRemoteValueSortByReadyToUse,
                    kRemoteValueSortByAvailableToSelect,
                    kRemoteValueSortByExpiringSoon ];
    
    [self fetchOffers:kRemoteValueSortByNewest];
}

-(void)fetchOffers:(NSString *)sort
{
    APRequestOffers *request = [[APRequestOffers alloc] init];
    request.AToken = @"FakeToken"; // TODO put real data here
    request.Distance = @(20.0);
    request.Lat = @(343.0032);
    request.Long = @(-893.32099);
    request.SortBy = sort;
    [request performRequest:^(id data, NSError *err) {
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

- (IBAction)changeFilter:(id)sender
{
    _actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Order", "Offer sort")
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:_sortNames[0],_sortNames[1],_sortNames[2],_sortNames[3],nil];
    
    [_actionSheet showInView:self.view.superview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_offers count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APOffer * offer = _offers[indexPath.row];
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewOfferDetail];
    [vc setValue:offer forKey:@"offer"];
    [self presentViewController:vc animated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APOffersCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDOffer forIndexPath:indexPath];
    APOffer * offer = _offers[indexPath.row];
    cell.businessName.text = offer.Nam;
    cell.offerDescription.text = offer.Description;
    cell.expiration.text = [NSString stringWithFormat:NSLocalizedString(@"Expires in %u days","OfferListingCell"),[offer.DaysToUse integerValue]];
    cell.accessoryType = [offer.Selected boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Picked: %d",buttonIndex);
    if( buttonIndex < 5 )
    {
        [self fetchOffers:_sortTypes[buttonIndex]];
    }
    [_actionSheet dismissWithClickedButtonIndex:5 animated:YES];
}

@end

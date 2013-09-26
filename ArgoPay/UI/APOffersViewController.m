//
//  APOffersViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APOffer.h"
#import "APMerchant.h"
#import "APRemoteAPI.h"

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
                    NSLocalizedString(@"Expiring Soon", "Offer sort type"),
                    NSLocalizedString(@"Recommended for You", "Offer sort type") ];

    APRemoteAPI *api = [APRemoteAPI sharedInstance];
    [api getOffers:^(id data, NSError *err) {
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
                                      otherButtonTitles:_sortNames[0],_sortNames[1],_sortNames[2],_sortNames[3],_sortNames[4],nil];
    
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
    cell.businessName.text = offer.merchant.name;
    cell.offerDescription.text = offer.description;
    cell.expiration.text = [NSString stringWithFormat:NSLocalizedString(@"Expires in %u days","OfferListingCell"),offer.daysToExpire];
    cell.accessoryType = [offer.selected boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Picked: %d",buttonIndex);
    if( buttonIndex < 5 )
    {
        _offers = [_offers arrayByOfferSort:buttonIndex+1];
        _filterTypeName.text = _sortNames[buttonIndex];
        [_offersTable reloadData];
    }
    [_actionSheet dismissWithClickedButtonIndex:5 animated:YES];
}

@end

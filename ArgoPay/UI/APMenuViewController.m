//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APReward.h"
#import "APMerchant.h"

@interface APMenuBaseController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@end

@implementation APMenuBaseController

APLOGRELEASE

-(void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * bbBack = [self barButtonForImage:kImageBack
                                                 title:@"Back"
                                                 block:^(APMenuBaseController *me, id sender)
    {
        [me.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    _navBar.topItem.leftBarButtonItem = bbBack;
}
                                          
@end

@interface APAccountViewController : APMenuBaseController

@end

@implementation APAccountViewController

@end

@interface APHistoryViewController : APMenuBaseController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@end

@implementation APHistoryViewController


@end

@interface APRewardsCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UIImageView *logo;
@property (weak,nonatomic) IBOutlet UILabel *merchantName;
@property (weak,nonatomic) IBOutlet UILabel *points;
@property (weak,nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak,nonatomic) IBOutlet UILabel *status;
@end

@implementation APRewardsCell
@end


@interface APRewardsViewController : APMenuBaseController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *rewardsTable;
@end

@implementation APRewardsViewController {
    NSArray * _rewards;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _rewards = [APReward rewardsForAccount];
    
    [self registerForBroadcast:kNotifyRewardStatusChange
                         block:^(APRewardsViewController *me, APReward *reward)
    {
        NSInteger counter = 0;
        for( APReward *test in me->_rewards )
        {
            if( [test.key isEqual:reward.key] )
                break;
            ++counter;
        }
         @synchronized(me) {
             [me->_rewardsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:counter inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationFade];
         }
    }];
}

-(void)redeemReward:(UIButton *)button
{
    APReward * reward = _rewards[button.tag];
    [reward redeem];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rewards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APRewardsCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDReward forIndexPath:indexPath];
    APReward * reward = _rewards[indexPath.row];
    
    cell.merchantName.text = reward.merchant.name;
    cell.points.text = [NSString stringWithFormat:@"%d",[reward.points intValue]];
    cell.value.text = [NSString stringWithFormat:@"$%.0f", [reward.credit floatValue]];
    if( reward.status == kRewardStatusRedeemable )
    {
        cell.status.hidden = YES;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];
        cell.redeemButton.hidden = NO;
        cell.redeemButton.tag = indexPath.row;
        [cell.redeemButton addTarget:self action:@selector(redeemReward:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if( reward.status == kRewardStatusReadyToUse )
    {
        cell.status.hidden = NO;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];
        cell.redeemButton.hidden = YES;
    }
    else if( reward.status == kRewardStatusSeekingRedemption )
    {
        cell.status.hidden = YES;
        cell.redeemButton.hidden = YES;
        cell.activity.hidden = NO;
        [cell.activity startAnimating];
    }
    else
    {
        cell.redeemButton.hidden = YES;
        cell.status.hidden = NO;
        cell.activity.hidden = YES;
        [cell.activity stopAnimating];        
    }
    return cell;
}

@end



@interface APMenuCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end

@implementation APMenuCell

@end

@interface APMenuViewController : UIViewController<UICollectionViewDataSource>

@end

@interface APMenuItem : NSObject
@property (nonatomic,strong) NSString * image;
@property (nonatomic,strong) NSString * label;
@property (nonatomic,strong) NSString * navVC;
@end

@implementation APMenuItem

+(id)miWithImage:(NSString *)image label:(NSString *)label vc:(NSString *)navVC
{
    APMenuItem * mi = [APMenuItem new];
    mi.image = image;
    mi.label = label;
    mi.navVC = navVC;
    return mi;
}

@end

static NSArray *menuItems()
{
    static NSArray * _items;
    
    if( !_items )
    {
        _items = @[ [APMenuItem miWithImage:kImageSettings label:@"Settings" vc:kViewSettings],
                    [APMenuItem miWithImage:kImageHistory label:@"History" vc:kViewHistory],
                    [APMenuItem miWithImage:kImageAccount label:@"Account" vc:kViewAccount],
                    [APMenuItem miWithImage:kImageRewards label:@"Rewards" vc:kViewRewards]];
    }
    
    return _items;
}

@implementation APMenuViewController

APLOGRELEASE

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [menuItems() count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    APMenuCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIDMenu forIndexPath:indexPath];
    APMenuItem * mi = menuItems()[indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:mi.image]];
    cell.title.text = mi.label;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    APMenuItem * mi = menuItems()[indexPath.row];
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:mi.navVC];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

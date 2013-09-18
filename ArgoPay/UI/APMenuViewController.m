//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"

@interface APMenuBaseController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@end

@implementation APMenuBaseController

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

@interface APRewardsViewController : APMenuBaseController

@end

@implementation APRewardsViewController
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

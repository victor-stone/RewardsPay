//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APPopup.h"

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
        _items = @[ [APMenuItem miWithImage:kImageSettings label: NSLocalizedString(@"Settings","menu") vc:kViewSettings],
                    [APMenuItem miWithImage:kImageHistory label: NSLocalizedString(@"History","menu") vc:kViewHistory],
                    [APMenuItem miWithImage:kImageAccount label: NSLocalizedString(@"ArgoCredit","menu") vc:kViewAccount],
                    [APMenuItem miWithImage:kImageRewards label: NSLocalizedString(@"Rewards","menu") vc:kViewRewards]];
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
    cell.imageView.image = [UIImage imageNamed:mi.image];
    cell.imageView.highlightedImage = [UIImage imageNamed:SELECTEDIMG(mi.image)];
    cell.title.text = mi.label;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    APMenuItem * mi = menuItems()[indexPath.row];
    [self presentVC:mi.navVC animated:YES
              completion:^{
                  //
              }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APPopup.h"
#import "APAccount.h"

@interface APMenuCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end

@implementation APMenuCell

@end

@interface APHomeViewController : UIViewController<UICollectionViewDataSource>

@end

typedef void (^APMenuItemBlock)(UIViewController *vc);

@interface APMenuItem : NSObject
@property (nonatomic,strong) NSString * image;
@property (nonatomic,strong) NSString * label;
@property (nonatomic,strong) NSString * navVC;
@property (nonatomic,strong) APMenuItemBlock block;
@end

@implementation APMenuItem

+(id)miWithImage:(NSString *)image label:(NSString *)label vc:(NSString *)navVC
{
    APMenuItem * mi = [APMenuItem new];
    mi.image = image;
    mi.label = label;
    mi.navVC = navVC;
    mi.block = nil;
    return mi;
}

+(id)miWithImage:(NSString *)image label:(NSString *)label block:(APMenuItemBlock)block
{
    APMenuItem * mi = [APMenuItem new];
    mi.image = image;
    mi.label = label;
    mi.navVC = nil;
    mi.block = [block copy];
    return mi;
}

@end

static NSArray *menuItems()
{
    static NSArray * _items;
    
    if( !_items )
    {
        _items = @[ [APMenuItem miWithImage:kImageSettings   label: NSLocalizedString(@"Settings","menu") vc:kViewSettings],
                    [APMenuItem miWithImage:kImageHistory    label: NSLocalizedString(@"History","menu") vc:kViewHistory],
                    [APMenuItem miWithImage:kImageAccount    label: NSLocalizedString(@"ArgoCredit","menu") vc:kViewAccount],
                    [APMenuItem miWithImage:kImageRewards    label: NSLocalizedString(@"Rewards","menu") vc:kViewRewards],
                    [APMenuItem miWithImage:kImageLogoutHome label: NSLocalizedString(@"Logout", "menu") block:^(UIViewController *vc) {
                        [[APAccount currentAccount] logUserOut];
                        [APPopup msgWithParent:vc.view
                                          text:NSLocalizedString(@"You have been logged out", @"from menu")
                                  dismissBlock:^{ [vc navigateTo:kViewOffers];}];}]
                    ];
    }
    
    return _items;
}

@implementation APHomeViewController

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
    if( mi.block )
    {
        mi.block(self);
    }
    else
    {
        [self presentVC:mi.navVC
               animated:YES
             completion:^{
                 [collectionView deselectItemAtIndexPath:indexPath animated:NO];
             }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

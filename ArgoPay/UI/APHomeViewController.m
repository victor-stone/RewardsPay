//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#import "APHomeViewController.h"
#import "APStrings.h"

@interface APHomeViewController () <UICollectionViewDataSource>

@end

@implementation APHomeViewController

APLOGRELEASE

#warning Need a logout strategy

-(BOOL)navigationBarHidden
{
    return YES;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5; // TODO: Is there a way to get the number of prototype cells?
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject performBlock:^{
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    } afterDelay:0.4];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"%@%d", kCellIDMenu, indexPath.row];
    return [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
}

-(IBAction)unwindFromError:(UIStoryboardSegue *)segue
{
    [self broadcast:kNotifyErrorViewClosed payload:segue.sourceViewController];
}
@end

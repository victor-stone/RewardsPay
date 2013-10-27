//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#import "APHomeViewController.h"
#import "APStrings.h"
#import "APAccount.h"

@interface APHomeViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewMenu;

@end

@implementation APHomeViewController 
APLOGRELEASE

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

-(IBAction)unwindFromLogout:(UIStoryboardSegue *)segue
{
    APAccount * account = [APAccount currentAccount];
    [account logUserOut];
}

-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    if( action == @selector(unwindFromLogout:) )
        return YES;
    
    return [super canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

@end

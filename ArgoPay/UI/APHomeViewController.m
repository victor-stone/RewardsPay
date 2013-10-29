//
//  APMenuViewController.m
//  ArgoPayMobile
//
//  Created by victor on 9/12/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//
#import "APStrings.h"
#import "APAccount.h"
#import "APTransactionViewController.h"
#import "VSNavigationViewController.h"

@interface APHomeViewController : APTransactionViewController
@end

@interface APHomeViewController () <UICollectionViewDataSource,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewMenu;
@end

@implementation APHomeViewController 
APLOGRELEASE

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
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log out", @"logout")
                                                     message:NSLocalizedString(@"Log out now?", @"logout")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Yes, Log out",@"logout")
                                           otherButtonTitles:NSLocalizedString(@"No, keep me logged in", @logout), nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        APAccount * account = [APAccount currentAccount];
        [account logUserOut];
    }
}

-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    if( action == @selector(unwindFromLogout:) )
        return YES;
    
    return [super canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

@end

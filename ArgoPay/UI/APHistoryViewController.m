//
//  APHistoryViewController.m
//  ArgoPay
//
//  Created by victor on 9/28/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APAccount.h"
#import "APPopup.h"

@interface APHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *amount;

@end

@implementation APHistoryCell
@end

@interface APHistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,
                                                                UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *transactionsTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;
@end

@implementation APHistoryViewController {
    NSArray *_allResults;
    NSArray *_historyItems;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self argoPayIze];
    [self addBackButton:_argoNavBar];

    [self fetchHistory:nil];
    
}

-(void)fetchHistory:(NSString *)sort
{
    APPopup *popup = [APPopup withNetActivity:self.view];
    APAccount *account = [APAccount currentAccount];
    APRequestStatementDetail *request = [[APRequestStatementDetail alloc] init];
    request.AToken = account.AToken;
    request.DateFrom = @"1970-01-02 00:00:00";
    request.DateTo   = @"2970-01-02 00:00:00";
    [request performRequest:^(NSArray *items, NSError *err) {
        [popup dismiss];
        if( err )
        {
            [self showError:err];
        }
        else
        {
            _allResults = items;
            _historyItems = [NSArray arrayWithArray:items];
            [_transactionsTable reloadData];
        }
    }];
}

- (IBAction)sort:(UISegmentedControl *)sender
{
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_historyItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APHistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIDHistory forIndexPath:indexPath];
    APStatementLine * item = _historyItems[indexPath.row];
    cell.date.text = [item formatDateField:@"Date" style:NSDateFormatterShortStyle];
    cell.name.text = item.Description;
    cell.amount.text = [NSString stringWithFormat:@"$%.2f", [item.Amount floatValue]] ;
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString   // called when text changes (including clear)
{
    if( searchString.length == 0 )
    {
        _historyItems = [NSArray arrayWithArray:_allResults];
    }
    else
    {
        searchString = [searchString lowercaseString];
        _historyItems = [_allResults select:^BOOL(APStatementLine *line) {
            NSString *test = [line.Description lowercaseString];
            return ( ([test rangeOfString:searchString].location == NSNotFound) ? NO : YES );
        }];
    }
    [_transactionsTable reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;                     // called when keyboard search button pressed
{
    [searchBar resignFirstResponder];
}

@end

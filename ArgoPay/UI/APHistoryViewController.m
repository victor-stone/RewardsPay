//
//  APHistoryViewController.m
//  ArgoPay
//
//  Created by victor on 9/28/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APStrings.h"
#import "APAccount.h"

@interface APHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *amount;

@end

@implementation APHistoryCell
@end

@interface APHistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *transactionsTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *argoNavBar;
@end

@implementation APHistoryViewController {
    NSArray *_historyItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton:_argoNavBar];

    [self fetchHistory:nil];
    
}

-(void)fetchHistory:(NSString *)sort
{
    APAccount *account = [APAccount currentAccount];
    APStatementRequest *request = [[APStatementRequest alloc] init];
    request.AToken = account.AToken;
    request.DateFrom = @"1970-01-02 00:00:00";
    request.DateTo   = @"2970-01-02 00:00:00";
    [request performRequest:^(NSArray *items, NSError *err) {
        if( err )
        {
            [self showError:err];
        }
        else
        {
            _historyItems = items;
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
    cell.amount = [NSString stringWithFormat:@"$%.2f", [item.Amount floatValue]] ;
    return cell;
}

@end

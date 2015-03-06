#import "StatsPostDetailsTableViewController.h"
#import "WPStatsGraphViewController.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsTwoColumnTableViewCell.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"

static CGFloat const StatsTableGraphHeight = 185.0f;
static CGFloat const StatsTableNoResultsHeight = 100.0f;
static CGFloat const StatsTableGroupHeaderHeight = 30.0f;
static NSString *const StatsTableSectionHeaderSimpleBorder = @"StatsTableSectionHeaderSimpleBorder";
static NSString *const StatsTableGroupHeaderCellIdentifier = @"GroupHeader";
static NSString *const StatsTableTwoColumnHeaderCellIdentifier = @"TwoColumnHeader";
static NSString *const StatsTableTwoColumnCellIdentifier = @"TwoColumnRow";
static NSString *const StatsTableLoadingIndicatorCellIdentifier = @"LoadingIndicator";
static NSString *const StatsTableGraphSelectableCellIdentifier = @"SelectableRow";
static NSString *const StatsTableGraphCellIdentifier = @"GraphRow";
static NSString *const StatsTableNoResultsCellIdentifier = @"NoResultsRow";

@interface StatsPostDetailsTableViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableDictionary *sectionData;
@property (nonatomic, strong) WPStatsGraphViewController *graphViewController;

@end

@implementation StatsPostDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sections = @[@(StatsSectionPostDetailsGraph), @(StatsSectionPostDetailsMonthsYears), @(StatsSectionPostDetailsAveragePerDay), @(StatsSectionPostDetailsRecentWeeks)];
    self.sectionData = [NSMutableDictionary new];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[StatsTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(retrieveStats) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.title = self.postTitle;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self retrieveStats];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self abortRetrieveStats];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
        case 2:
        case 3:
        {
            StatsSection statsSection = [self statsSectionForTableViewSection:section];
            StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
            NSUInteger numberOfRows = [statsGroup numberOfRows];
            return 2 + numberOfRows + (numberOfRows == 0 ? 1 : 0);
        }
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self cellIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];

    if ([identifier isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        StatsItem *statsItem = [statsGroup statsItemForTableViewRow:indexPath.row];
        
        [self configureTwoColumnRowCell:cell
                           withLeftText:statsItem.label
                              rightText:statsItem.value
                            andImageURL:statsItem.iconURL
                            indentLevel:statsItem.depth
                             indentable:NO
                             expandable:statsItem.children.count > 0
                               expanded:statsItem.expanded
                             selectable:statsItem.actions.count > 0 || statsItem.children.count > 0
                        forStatsSection:statsSection];
    } else if ([identifier isEqualToString:StatsTableTwoColumnHeaderCellIdentifier]) {
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        [self configureSectionTwoColumnHeaderCell:cell withStatsGroup:statsGroup];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    StatsTableSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    return headerView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    StatsTableSectionHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:StatsTableSectionHeaderSimpleBorder];
    footerView.footer = YES;
    
    return footerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    
    if ([cellIdentifier isEqualToString:StatsTableGraphCellIdentifier]) {
        return StatsTableGraphHeight;
    } else if ([cellIdentifier isEqualToString:StatsTableGroupHeaderCellIdentifier]) {
        return StatsTableGroupHeaderHeight;
    } else if ([cellIdentifier isEqualToString:StatsTableNoResultsCellIdentifier]) {
        return StatsTableNoResultsHeight;
    }
    
    return 44.0f;
}


#pragma mark - Private methods

- (void)retrieveStats
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.sectionData.count == 0) {
        self.sectionData[@(StatsSectionPostDetailsGraph)] = [StatsVisits new];
        self.sectionData[@(StatsSectionPostDetailsMonthsYears)] = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsMonthsYears andStatsSubSection:StatsSubSectionNone];
        self.sectionData[@(StatsSectionPostDetailsAveragePerDay)] = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsAveragePerDay andStatsSubSection:StatsSubSectionNone];
        self.sectionData[@(StatsSectionPostDetailsRecentWeeks)] = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsRecentWeeks andStatsSubSection:StatsSubSectionNone];
    }
    
    [self.statsService retrievePostDetailsStatsForPostID:self.postID
                                   withCompletionHandler:^(StatsVisits *visits, StatsGroup *monthsYears, StatsGroup *averagePerDay, StatsGroup *recentWeeks, NSError *error)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.refreshControl endRefreshing];
        
        monthsYears.offsetRows = 2;
        averagePerDay.offsetRows = 2;
        recentWeeks.offsetRows = 2;

        self.sectionData[@(StatsSectionPostDetailsGraph)] = visits;
        self.sectionData[@(StatsSectionPostDetailsMonthsYears)] = monthsYears;
        self.sectionData[@(StatsSectionPostDetailsAveragePerDay)] = averagePerDay;
        self.sectionData[@(StatsSectionPostDetailsRecentWeeks)] = recentWeeks;
        
        [self.tableView reloadData];
    }];
    
}


- (void)abortRetrieveStats
{
    [self.statsService cancelAnyRunningOperations];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    
    if (indexPath.section == 0) {
        identifier = StatsTableGraphCellIdentifier;
    } else {
        switch (indexPath.row) {
            case 0:
                identifier = StatsTableGroupHeaderCellIdentifier;
                break;
            case 1:
                identifier = StatsTableTwoColumnHeaderCellIdentifier;
                break;
            default:
                identifier = StatsTableTwoColumnCellIdentifier;
                break;
        }
    }

    return identifier;
}


- (void)configureTwoColumnRowCell:(UITableViewCell *)cell
                     withLeftText:(NSString *)leftText
                        rightText:(NSString *)rightText
                      andImageURL:(NSURL *)imageURL
                      indentLevel:(NSUInteger)indentLevel
                       indentable:(BOOL)indentable
                       expandable:(BOOL)expandable
                         expanded:(BOOL)expanded
                       selectable:(BOOL)selectable
                  forStatsSection:(StatsSection)statsSection
{
    BOOL showCircularIcon = (statsSection == StatsSectionComments || statsSection == StatsSectionFollowers);
    
    StatsTwoColumnTableViewCell *statsCell = (StatsTwoColumnTableViewCell *)cell;
    statsCell.leftText = leftText;
    statsCell.rightText = rightText;
    statsCell.imageURL = imageURL;
    statsCell.showCircularIcon = showCircularIcon;
    statsCell.indentLevel = indentLevel;
    statsCell.indentable = indentable;
    statsCell.expandable = expandable;
    statsCell.expanded = expanded;
    statsCell.selectable = selectable;
    [statsCell doneSettingProperties];
}


- (void)configureSectionTwoColumnHeaderCell:(UITableViewCell *)cell withStatsGroup:(StatsGroup *)statsGroup
{
    NSString *leftText = statsGroup.titlePrimary;
    NSString *rightText = statsGroup.titleSecondary;
    
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
}


- (StatsSection)statsSectionForTableViewSection:(NSInteger)section
{
    return (StatsSection)[self.sections[section] integerValue];
}


- (id)statsDataForStatsSection:(StatsSection)statsSection
{
    return self.sectionData[@(statsSection)];
}


@end

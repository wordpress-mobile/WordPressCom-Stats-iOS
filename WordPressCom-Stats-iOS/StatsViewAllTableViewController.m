#import "StatsViewAllTableViewController.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsTwoColumnTableViewCell.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"

static NSString *const StatsTableSectionHeaderSimpleBorder = @"StatsTableSectionHeaderSimpleBorder";
static NSString *const StatsTableGroupHeaderCellIdentifier = @"GroupHeader";
static NSString *const StatsTableTwoColumnHeaderCellIdentifier = @"TwoColumnHeader";
static NSString *const StatsTableTwoColumnCellIdentifier = @"TwoColumnRow";
static NSString *const StatsTableLoadingIndicatorCellIdentifier = @"LoadingIndicator";

@interface StatsViewAllTableViewController ()

@property (nonatomic, strong) StatsGroup *statsGroup;

@end

@implementation StatsViewAllTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[StatsTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(retrieveStats) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.statsGroup = [[StatsGroup alloc] initWithStatsSection:self.statsSection andStatsSubSection:self.statsSubSection];
    self.title = self.statsGroup.groupTitle;
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL isDataLoaded = self.statsGroup.items != nil;
    NSInteger numberOfRows = 1 + (isDataLoaded ? self.statsGroup.numberOfRows : 1);
    
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    switch (indexPath.row) {
        case 0:
            identifier = StatsTableTwoColumnHeaderCellIdentifier;
            break;
        case 1:
            if (self.statsGroup.items == nil) {
                identifier = StatsTableLoadingIndicatorCellIdentifier;
                break;
            }
        default:
            identifier = StatsTableTwoColumnCellIdentifier;
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([identifier isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        StatsItem *item = [self.statsGroup statsItemForTableViewRow:indexPath.row];
        
        [self configureTwoColumnRowCell:cell
                           withLeftText:item.label
                              rightText:item.value
                            andImageURL:item.iconURL
                            indentLevel:item.depth
                             indentable:NO
                             expandable:item.children.count > 0
                               expanded:item.expanded
                             selectable:item.actions.count > 0 || item.children.count > 0
                        forStatsSection:self.statsSection];
    } else if ([identifier isEqualToString:StatsTableLoadingIndicatorCellIdentifier]) {
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:100];
        [indicator startAnimating];
    } else if ([identifier isEqualToString:StatsTableTwoColumnHeaderCellIdentifier]) {
        [self configureSectionTwoColumnHeaderCell:cell];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    StatsItem *statsItem = [self.statsGroup statsItemForTableViewRow:indexPath.row];
    
    if (statsItem.children.count > 0) {
        BOOL insert = !statsItem.isExpanded;
        NSInteger numberOfRowsBefore = statsItem.numberOfRows - 1;
        statsItem.expanded = !statsItem.isExpanded;
        NSInteger numberOfRowsAfter = statsItem.numberOfRows - 1;
        
        StatsTwoColumnTableViewCell *cell = (StatsTwoColumnTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.expanded = statsItem.isExpanded;
        [cell doneSettingProperties];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        
        NSInteger numberOfRows = insert ? numberOfRowsAfter : numberOfRowsBefore;
        for (NSInteger row = 1; row <= numberOfRows; ++row) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:(row + indexPath.row) inSection:indexPath.section]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (insert) {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        } else {
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
        
        [self.tableView endUpdates];
    } else if (statsItem.actions.count > 0) {
        for (StatsItemAction *action in statsItem.actions) {
            if (action.defaultAction) {
                if ([self.statsDelegate respondsToSelector:@selector(statsViewController:openURL:)]) {
                    WPStatsViewController *statsViewController = (WPStatsViewController *)self.navigationController;
                    [self.statsDelegate statsViewController:statsViewController openURL:action.url];
                } else {
#ifndef AF_APP_EXTENSIONS
                    [[UIApplication sharedApplication] openURL:action.url];
#endif
                }
                break;
            }
        }
    }
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}


#pragma mark - Private methods

- (void)retrieveStats
{
#ifndef AF_APP_EXTENSIONS
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
    
    if (self.statsGroup) {
        self.statsGroup = [[StatsGroup alloc] initWithStatsSection:self.statsSection andStatsSubSection:self.statsSubSection];
        [self.tableView reloadData];
    }
    
    StatsGroupCompletion completion = ^(StatsGroup *group, NSError *error) {
#ifndef AF_APP_EXTENSIONS
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
        [self.refreshControl endRefreshing];

        self.statsGroup = group;
        self.statsGroup.offsetRows = 1;
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (int row = 1; row < (1 + self.statsGroup.items.count); ++row) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    };
    
    if (self.statsSection == StatsSectionPosts) {
        [self.statsService retrievePostsForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionReferrers) {
        [self.statsService retrieveReferrersForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionClicks) {
        [self.statsService retrieveClicksForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionCountry) {
        [self.statsService retrieveCountriesForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionVideos) {
        [self.statsService retrieveVideosForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionAuthors) {
        [self.statsService retrieveAuthorsForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionSearchTerms) {
        [self.statsService retrieveSearchTermsForDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    } else if (self.statsSection == StatsSectionFollowers) {
        StatsFollowerType followerType = self.statsSubSection == StatsSubSectionFollowersDotCom ? StatsFollowerTypeDotCom : StatsFollowerTypeEmail;
        [self.statsService retrieveFollowersOfType:followerType forDate:self.selectedDate andUnit:self.periodUnit withCompletionHandler:completion];
    }
}


- (void)abortRetrieveStats
{
    [self.statsService cancelAnyRunningOperations];
#ifndef AF_APP_EXTENSIONS
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
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


- (void)configureSectionTwoColumnHeaderCell:(UITableViewCell *)cell
{
    NSString *leftText = self.statsGroup.titlePrimary;
    NSString *rightText = self.statsGroup.titleSecondary;
    
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
}


@end

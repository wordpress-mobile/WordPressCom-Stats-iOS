#import "StatsPostDetailsTableViewController.h"
#import "WPStatsGraphViewController.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsTwoColumnTableViewCell.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"
#import <WordPressCom-Analytics-iOS/WPAnalytics.h>

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

@interface StatsPostDetailsTableViewController () <WPStatsGraphViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *sectionData;
@property (nonatomic, strong) WPStatsGraphViewController *graphViewController;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, assign) BOOL isRefreshing;
@end

@implementation StatsPostDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WPAnalytics track:WPAnalyticsStatStatsSinglePostAccessed];
    
    self.sections = [@[@(StatsSectionPostDetailsLoadingIndicator), @(StatsSectionPostDetailsGraph), @(StatsSectionPostDetailsMonthsYears), @(StatsSectionPostDetailsAveragePerDay), @(StatsSectionPostDetailsRecentWeeks)] mutableCopy];
    self.sectionData = [NSMutableDictionary new];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[StatsTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    [self setupRefreshControl];
    
    self.graphViewController = [WPStatsGraphViewController new];
    self.graphViewController.allowDeselection = NO;
    self.graphViewController.graphDelegate = self;
    [self addChildViewController:self.graphViewController];
    [self.graphViewController didMoveToParentViewController:self];
    
    self.title = self.postTitle;
    
    self.sectionData[@(StatsSectionPostDetailsGraph)] = [StatsVisits new];
    self.sectionData[@(StatsSectionPostDetailsMonthsYears)] = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsMonthsYears andStatsSubSection:StatsSubSectionNone];
    self.sectionData[@(StatsSectionPostDetailsAveragePerDay)] = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsAveragePerDay andStatsSubSection:StatsSubSectionNone];
    self.sectionData[@(StatsSectionPostDetailsRecentWeeks)] = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsRecentWeeks andStatsSubSection:StatsSubSectionNone];
    [self.tableView reloadData];
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
    return self.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    StatsSection statsSection = [self statsSectionForTableViewSection:section];
    
    switch (statsSection) {
        case StatsSectionPostDetailsLoadingIndicator:
            return self.isRefreshing ? 1 : 0;
        case StatsSectionPostDetailsGraph:
            return 2;
        case StatsSectionPostDetailsAveragePerDay:
        case StatsSectionPostDetailsMonthsYears:
        case StatsSectionPostDetailsRecentWeeks:
        {
            StatsSection statsSection = [self statsSectionForTableViewSection:section];
            StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
            NSUInteger numberOfRows = [statsGroup numberOfRows];
            return 2 + numberOfRows + (numberOfRows == 0 ? 1 : 0);
        }
        default:
            return 0;
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self cellIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];

    if ([identifier isEqualToString:StatsTableGraphCellIdentifier]) {
        [self configureSectionGraphCell:cell];
    } else if ([identifier isEqualToString:StatsTableGraphSelectableCellIdentifier]) {
        [self configureSectionGraphSelectableCell:cell];
    } else if ([identifier isEqualToString:StatsTableGroupHeaderCellIdentifier]) {
        [self configureSectionGroupHeaderCell:(StatsStandardBorderedTableViewCell *)cell
                             withStatsSection:statsSection];
    } else if ([identifier isEqualToString:StatsTableTwoColumnCellIdentifier]) {
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
    } else if ([identifier isEqualToString:StatsTableLoadingIndicatorCellIdentifier]) {
        cell.backgroundColor = self.tableView.backgroundColor;
    }
    
    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];

    if (statsSection == StatsSectionPostDetailsGraph && indexPath.row > 0) {
        for (NSIndexPath *selectedIndexPath in [tableView indexPathsForSelectedRows]) {
            [tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
        }
        
        return indexPath;
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        // Disable taps on rows without children
        StatsGroup *group = [self statsDataForStatsSection:statsSection];
        StatsItem *item = [group statsItemForTableViewRow:indexPath.row];
        
        BOOL hasChildItems = item.children.count > 0;
        // TODO :: Look for default action boolean
        BOOL hasDefaultAction = item.actions.count > 0;
        NSIndexPath *newIndexPath = hasChildItems || hasDefaultAction ? indexPath : nil;
        
        return newIndexPath;
    }
    
    return nil;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self statsSectionForTableViewSection:indexPath.section] == StatsSectionPostDetailsGraph && indexPath.row > 0) {
        return nil;
    }
    
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    if (statsSection == StatsSectionPostDetailsGraph && indexPath.row > 0) {
        NSIndexPath *graphIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[graphIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        StatsItem *statsItem = [statsGroup statsItemForTableViewRow:indexPath.row];
        
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
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self statsSectionForTableViewSection:section] != StatsSectionPostDetailsLoadingIndicator) {
        StatsTableSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:StatsTableSectionHeaderSimpleBorder];
        
        return headerView;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self statsSectionForTableViewSection:section] != StatsSectionPostDetailsLoadingIndicator) {
        StatsTableSectionHeaderView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:StatsTableSectionHeaderSimpleBorder];
        footerView.footer = YES;
        
        return footerView;
    }
    
    return nil;
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
#ifndef AF_APP_EXTENSIONS
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
    
    if (self.refreshControl.isRefreshing == NO) {
        self.refreshControl = nil;
        self.isRefreshing = YES;
        [self.tableView reloadData];
    }
    
    [self.statsService retrievePostDetailsStatsForPostID:self.postID
                                   withCompletionHandler:^(StatsVisits *visits, StatsGroup *monthsYears, StatsGroup *averagePerDay, StatsGroup *recentWeeks, NSError *error)
    {
#ifndef AF_APP_EXTENSIONS
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
        [self setupRefreshControl];
        [self.refreshControl endRefreshing];

        self.isRefreshing = NO;
        
        monthsYears.offsetRows = 2;
        averagePerDay.offsetRows = 2;
        recentWeeks.offsetRows = 2;

        self.sectionData[@(StatsSectionPostDetailsGraph)] = visits;
        self.sectionData[@(StatsSectionPostDetailsMonthsYears)] = monthsYears;
        self.sectionData[@(StatsSectionPostDetailsAveragePerDay)] = averagePerDay;
        self.sectionData[@(StatsSectionPostDetailsRecentWeeks)] = recentWeeks;

        self.selectedDate = [visits.statsData.lastObject date];
        [self.tableView reloadData];
        
        
        NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionPostDetailsGraph)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:sectionNumber];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
    
}


- (void)abortRetrieveStats
{
    [self.statsService cancelAnyRunningOperations];
#ifndef AF_APP_EXTENSIONS
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
}


- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    if (statsSection == StatsSectionPostDetailsLoadingIndicator) {
        identifier = StatsTableLoadingIndicatorCellIdentifier;
    } else if (statsSection == StatsSectionPostDetailsGraph) {
        switch (indexPath.row) {
            case 0:
                identifier = StatsTableGraphCellIdentifier;
                break;
            case 1:
                identifier = StatsTableGraphSelectableCellIdentifier;
        }
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


- (void)configureSectionGraphCell:(UITableViewCell *)cell
{
    StatsVisits *visits = [self statsDataForStatsSection:StatsSectionPostDetailsGraph];
    
    if (![[cell.contentView subviews] containsObject:self.graphViewController.view]) {
        UIView *graphView = self.graphViewController.view;
        [graphView removeFromSuperview];
        graphView.frame = CGRectMake(8.0f, 0.0f, CGRectGetWidth(cell.contentView.bounds) - 16.0f, StatsTableGraphHeight - 1.0);
        graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:graphView];
    }
    
    self.graphViewController.currentSummaryType = StatsSummaryTypeViews;
    self.graphViewController.visits = visits;
    [self.graphViewController doneSettingProperties];
    [self.graphViewController.collectionView reloadData];
    [self.graphViewController selectGraphBarWithDate:self.selectedDate];
}


- (void)configureSectionGraphSelectableCell:(UITableViewCell *)cell
{
    UILabel *iconLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:200];
    UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:300];
    
    StatsVisits *visits = [self statsDataForStatsSection:StatsSectionPostDetailsGraph];
    StatsSummary *summary = visits.statsDataByDate[self.selectedDate];
    
    cell.selected = YES;
    
    iconLabel.text = @"";
    textLabel.text = [NSLocalizedString(@"Views", @"") uppercaseStringWithLocale:[NSLocale currentLocale]];
    valueLabel.text = summary.views;
}


- (void)configureSectionGroupHeaderCell:(StatsStandardBorderedTableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
    NSString *headerText = statsGroup.groupTitle;
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = headerText;
    
    cell.bottomBorderEnabled = NO;
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
    StatsTwoColumnTableViewCell *statsCell = (StatsTwoColumnTableViewCell *)cell;
    statsCell.leftText = leftText;
    statsCell.rightText = rightText;
    statsCell.imageURL = imageURL;
    statsCell.showCircularIcon = NO;
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


- (void)setupRefreshControl
{
    if (self.refreshControl) {
        return;
    }
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(retrieveStats) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.isRefreshing = NO;
}


#pragma mark - WPStatsGraphViewControllerDelegate methods


- (void)statsGraphViewController:(WPStatsGraphViewController *)controller didSelectDate:(NSDate *)date
{
    self.selectedDate = date;
    
    [self.tableView reloadData];
    
    NSUInteger section = [self.sections indexOfObject:@(StatsSectionPostDetailsGraph)];
    if (section != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:section];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


- (void)setIsRefreshing:(BOOL)isRefreshing
{
    _isRefreshing = isRefreshing;
    
    if (_isRefreshing && [self.sections containsObject:@(StatsSectionPostDetailsLoadingIndicator)] == NO) {
        [self.sections insertObject:@(StatsSectionPostDetailsLoadingIndicator) atIndex:0];
    } else if (_isRefreshing == NO && [self.sections containsObject:@(StatsSectionPostDetailsLoadingIndicator)]) {
        [self.sections removeObject:@(StatsSectionPostDetailsLoadingIndicator)];
    }
}

@end

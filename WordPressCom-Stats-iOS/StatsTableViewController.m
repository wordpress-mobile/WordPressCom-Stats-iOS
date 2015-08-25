#import "StatsTableViewController.h"
#import "WPStatsGraphViewController.h"
#import "WPStatsService.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "WPStyleGuide+Stats.h"
#import <WordPress-iOS-Shared/WPImageSource.h>
#import "StatsTableSectionHeaderView.h"
#import "StatsDateUtilities.h"
#import "StatsTwoColumnTableViewCell.h"
#import "StatsViewAllTableViewController.h"
#import "StatsPostDetailsTableViewController.h"
#import "StatsSection.h"
#import "WPFontManager+Stats.h"
#import <WordPressCom-Analytics-iOS/WPAnalytics.h>

static CGFloat const StatsTableGraphHeight = 185.0f;
static CGFloat const StatsTableNoResultsHeight = 100.0f;
static CGFloat const StatsTableGroupHeaderHeight = 30.0f;
static NSInteger const StatsTableRowDataOffsetStandard = 2;
static NSInteger const StatsTableRowDataOffsetWithoutGroupHeader = 1;
static NSInteger const StatsTableRowDataOffsetWithGroupSelector = 3;
static NSInteger const StatsTableRowDataOffsetWithGroupSelectorAndTotal = 4;
static NSString *const StatsTableGroupHeaderCellIdentifier = @"GroupHeader";
static NSString *const StatsTableGroupSelectorCellIdentifier = @"GroupSelector";
static NSString *const StatsTableGroupTotalsCellIdentifier = @"GroupTotalsRow";
static NSString *const StatsTableTwoColumnHeaderCellIdentifier = @"TwoColumnHeader";
static NSString *const StatsTableTwoColumnCellIdentifier = @"TwoColumnRow";
static NSString *const StatsTableGraphSelectableCellIdentifier = @"SelectableRow";
static NSString *const StatsTableViewAllCellIdentifier = @"MoreRow";
static NSString *const StatsTableGraphCellIdentifier = @"GraphRow";
static NSString *const StatsTableNoResultsCellIdentifier = @"NoResultsRow";
static NSString *const StatsTablePeriodHeaderCellIdentifier = @"PeriodHeader";
static NSString *const StatsTableSectionHeaderSimpleBorder = @"StatsTableSectionHeaderSimpleBorder";
static NSString *const StatsTableViewWebVersionCellIdentifier = @"WebVersion";

@interface StatsTableViewController () <WPStatsGraphViewControllerDelegate>

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableDictionary *sectionData;
@property (nonatomic, strong) WPStatsGraphViewController *graphViewController;
@property (nonatomic, assign) StatsPeriodUnit selectedPeriodUnit;
@property (nonatomic, assign) StatsSummaryType selectedSummaryType;
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation StatsTableViewController

- (void)awakeFromNib
{
    // Force load fonts from bundle
    [WPFontManager openSansBoldFontOfSize:1.0f];
    [WPFontManager openSansRegularFontOfSize:1.0f];
    [WPFontManager noticonsReguarFontOfSize:1.0f];

    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[StatsTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    [self setupRefreshControl];
    
    // Posts, Referrers, Clicks, Authors, Countries, Search Terms, Published, Videos, Comments, Tags, Followers, Publicize
    self.sections =     @[ @(StatsSectionGraph),
                           @(StatsSectionPeriodHeader),
                           @(StatsSectionPosts),
                           @(StatsSectionReferrers),
                           @(StatsSectionClicks),
                           @(StatsSectionAuthors),
                           @(StatsSectionCountry),
                           @(StatsSectionSearchTerms),
                           @(StatsSectionEvents),
                           @(StatsSectionVideos),
                           @(StatsSectionWebVersion)];
    
    [self wipeDataAndSeedGroups];
    
    self.graphViewController = [WPStatsGraphViewController new];
    
    [self resetDateToTodayForSite];
    self.selectedPeriodUnit = StatsPeriodUnitDay;
    self.selectedSummaryType = StatsSummaryTypeViews;
    self.graphViewController.allowDeselection = NO;
    self.graphViewController.graphDelegate = self;
    [self addChildViewController:self.graphViewController];
    [self.graphViewController didMoveToParentViewController:self];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self retrieveStatsSkipGraph:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self trackViewControllerAnalytics];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self resetDateToTodayForSite];
    [self retrieveStatsSkipGraph:NO];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    StatsSection statsSection = [self statsSectionForTableViewSection:section];
    id data = [self statsDataForStatsSection:statsSection];
    
    switch (statsSection) {
        case StatsSectionGraph:
            return 5;
        case StatsSectionPeriodHeader:
        case StatsSectionWebVersion:
            return 1;
            
        // TODO :: Pull offset from StatsGroup
        default:
        {
            StatsGroup *group = (StatsGroup *)data;
            NSInteger count = (NSInteger)group.numberOfRows;
            
            if (statsSection == StatsSectionComments) {
                count += StatsTableRowDataOffsetWithGroupSelector;
            } else if (statsSection == StatsSectionFollowers) {
                count += StatsTableRowDataOffsetWithGroupSelectorAndTotal;
                
                if (group.errorWhileRetrieving) {
                    count--;
                }
            } else if (statsSection == StatsSectionEvents) {
                if (count == 0) {
                    count = StatsTableRowDataOffsetStandard;
                } else {
                    count += StatsTableRowDataOffsetWithoutGroupHeader;
                }
            } else {
                count += StatsTableRowDataOffsetStandard;
            }
            
            if (group.moreItemsExist) {
                count++;
            }
            
            return count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Tweak for Storyboards in iOS 8 SDK breaking constraints in iOS 7
    // Taken from: http://stackoverflow.com/questions/19132908/auto-layout-constraints-issue-on-ios7-in-uitableviewcell
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 && !CGRectEqualToRect(cell.bounds, cell.contentView.frame)) {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate methods


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self statsSectionForTableViewSection:section] != StatsSectionPeriodHeader) {
        StatsTableSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:StatsTableSectionHeaderSimpleBorder];
        
        return headerView;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self statsSectionForTableViewSection:section] != StatsSectionPeriodHeader) {
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


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    if (statsSection == StatsSectionGraph && indexPath.row > 0) {
        for (NSIndexPath *selectedIndexPath in [tableView indexPathsForSelectedRows]) {
            [tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
        }
        
        return indexPath;
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableViewAllCellIdentifier]) {
        return indexPath;
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableViewWebVersionCellIdentifier]) {
        return indexPath;
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        // Disable taps on rows without children
        StatsGroup *group = [self statsDataForStatsSection:statsSection];
        StatsItem *item = [group statsItemForTableViewRow:indexPath.row];
        
        BOOL hasChildItems = item.children.count > 0;
        // TODO :: Look for default action boolean
        BOOL hasDefaultAction = item.actions.count > 0;
        NSIndexPath *newIndexPath = (hasChildItems || hasDefaultAction) ? indexPath : nil;
        
        return newIndexPath;
    }
    
    return nil;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self statsSectionForTableViewSection:indexPath.section] == StatsSectionGraph && indexPath.row > 0) {
        return nil;
    }
    
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    if (statsSection == StatsSectionGraph && indexPath.row > 0) {
        self.selectedSummaryType = (StatsSummaryType)(indexPath.row - 1);
        
        NSIndexPath *graphIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[graphIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        StatsItem *statsItem = [statsGroup statsItemForTableViewRow:indexPath.row];
        
        // Do nothing for posts - handled by segue to show post details
        if (statsSection == StatsSectionPosts || (statsSection == StatsSectionAuthors && statsItem.parent != nil)) {
            return;
        }

        if (statsItem.children.count > 0) {
            BOOL insert = !statsItem.isExpanded;
            NSInteger numberOfRowsBefore = (NSInteger)statsItem.numberOfRows - 1;
            statsItem.expanded = !statsItem.isExpanded;
            NSInteger numberOfRowsAfter = (NSInteger)statsItem.numberOfRows - 1;

            StatsTwoColumnTableViewCell *cell = (StatsTwoColumnTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.expanded = statsItem.isExpanded;
            [cell doneSettingProperties];

            NSMutableArray *indexPaths = [NSMutableArray new];
            
            NSInteger numberOfRows = insert ? numberOfRowsAfter : numberOfRowsBefore;
            for (NSInteger row = 1; row <= numberOfRows; ++row) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:(row + indexPath.row) inSection:indexPath.section]];
            }
            
            // Reload row one above to get rid of the double border
            NSIndexPath *previousRowIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[previousRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableViewWebVersionCellIdentifier]) {
        [WPAnalytics track:WPAnalyticsStatStatsOpenedWebVersion];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if ([self.statsDelegate respondsToSelector:@selector(statsViewController:didSelectViewWebStatsForSiteID:)]) {
            WPStatsViewController *statsViewController = (WPStatsViewController *)self.navigationController;
            [self.statsDelegate statsViewController:statsViewController didSelectViewWebStatsForSiteID:self.statsService.siteId];
        } else {
#ifndef AF_APP_EXTENSIONS
            NSURL *webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://wordpress.com/stats/%@", self.statsService.siteId]];
            [[UIApplication sharedApplication] openURL:webURL];
#endif
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfSections = [self.tableView numberOfSections];
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:(numberOfSections - 1)];
    
    if (indexPath.section == (numberOfSections - 1) && indexPath.row == (numberOfRows - 1)) {
        [WPAnalytics track:WPAnalyticsStatStatsScrolledToBottom];
    }
}


#pragma mark - Segue methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender
{
    if ([identifier isEqualToString:@"PostDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        StatsItem *statsItem = [statsGroup statsItemForTableViewRow:indexPath.row];

        // Only fire the segue for the posts section or authors if a nested row
        return statsSection == StatsSectionPosts || (statsSection == StatsSectionAuthors && statsItem.parent != nil);
    }
    
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    [super prepareForSegue:segue sender:sender];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    if ([segue.destinationViewController isKindOfClass:[StatsViewAllTableViewController class]]) {
        [WPAnalytics track:WPAnalyticsStatStatsViewAllAccessed];

        StatsViewAllTableViewController *viewAllVC = (StatsViewAllTableViewController *)segue.destinationViewController;
        viewAllVC.selectedDate = self.selectedDate;
        viewAllVC.periodUnit = self.selectedPeriodUnit;
        viewAllVC.statsSection = statsSection;
        viewAllVC.statsSubSection = StatsSubSectionNone;
        viewAllVC.statsService = self.statsService;
        viewAllVC.statsDelegate = self.statsDelegate;
    } else if ([segue.destinationViewController isKindOfClass:[StatsPostDetailsTableViewController class]]) {
        [WPAnalytics track:WPAnalyticsStatStatsSinglePostAccessed];
        
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        StatsItem *statsItem = [statsGroup statsItemForTableViewRow:indexPath.row];

        StatsPostDetailsTableViewController *postVC = (StatsPostDetailsTableViewController *)segue.destinationViewController;
        postVC.postID = statsItem.itemID;
        postVC.postTitle = statsItem.label;
        postVC.statsService = self.statsService;
        postVC.statsDelegate = self.statsDelegate;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - WPStatsGraphViewControllerDelegate methods


- (void)statsGraphViewController:(WPStatsGraphViewController *)controller didSelectDate:(NSDate *)date
{
    [WPAnalytics track:WPAnalyticsStatStatsTappedBarChart];

    self.selectedDate = date;

    NSInteger section = (NSInteger)[self.sections indexOfObject:@(StatsSectionPeriodHeader)];
    if (section != NSNotFound) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(NSUInteger)section];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    
    // Reset the data (except the graph) and refresh
    id graphData = self.sectionData[@(StatsSectionGraph)];
    [self wipeDataAndSeedGroups];
    self.sectionData[@(StatsSectionGraph)] = graphData;

    [self.tableView reloadData];
    
    section = (NSInteger)[self.sections indexOfObject:@(StatsSectionGraph)];
    if (section != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.selectedSummaryType + 1) inSection:section];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [self retrieveStatsSkipGraph:YES];
}


#pragma mark - Stats retrieval methods


- (IBAction)refreshCurrentStats:(UIRefreshControl *)sender
{
    [self resetDateToTodayForSite];
    [self.statsService expireAllItemsInCacheForPeriodStats];
    [self retrieveStatsSkipGraph:NO];
}


- (void)changeGraphPeriod:(StatsPeriodUnit)toPeriod
{
    self.selectedPeriodUnit = toPeriod;
    [self resetDateToTodayForSite];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self.sections indexOfObject:@(StatsSectionPeriodHeader)]];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

    [self wipeDataAndSeedGroups];
    [self.tableView reloadData];
    
    [self retrieveStatsSkipGraph:NO];
    
    [self trackViewControllerAnalytics];
}


- (void)switchToSummaryType:(StatsSummaryType)summaryType
{
    self.selectedSummaryType = summaryType;
    [self changeGraphPeriod:StatsPeriodUnitDay];
}


- (void)retrieveStatsSkipGraph:(BOOL)skipGraph
{
#ifndef AF_APP_EXTENSIONS
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
    
    if ([self.statsProgressViewDelegate respondsToSelector:@selector(statsViewControllerDidBeginLoadingStats:)]
        && self.refreshControl.isRefreshing == NO) {
        self.refreshControl = nil;
    }
    
    [self.statsService retrieveAllStatsForDate:self.selectedDate
                                       andUnit:self.selectedPeriodUnit
                    withVisitsCompletionHandler:^(StatsVisits *visits, NSError *error)
     {
         if (skipGraph) {
             return;
         }
         
         self.sectionData[@(StatsSectionGraph)] = visits;
         
         if (visits.errorWhileRetrieving == NO) {
             self.selectedDate = ((StatsSummary *)visits.statsData.lastObject).date;
         }
         
         [self.tableView reloadData];
         
         NSInteger sectionNumber = (NSInteger)[self.sections indexOfObject:@(StatsSectionGraph)];
         NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.selectedSummaryType + 1) inSection:sectionNumber];
         [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
     }
                       eventsCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetWithoutGroupHeader;
         self.sectionData[@(StatsSectionEvents)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionEvents)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                         postsCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionPosts)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionPosts)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                     referrersCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionReferrers)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionReferrers)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                        clicksCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionClicks)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionClicks)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                       countryCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionCountry)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionCountry)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                        videosCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionVideos)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionVideos)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                      authorsCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionAuthors)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionAuthors)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                  searchTermsCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionSearchTerms)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionSearchTerms)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                                 progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
    {
        if (numberOfFinishedOperations == 0 && [self.statsProgressViewDelegate respondsToSelector:@selector(statsViewControllerDidBeginLoadingStats:)]) {
            [self.statsProgressViewDelegate statsViewControllerDidBeginLoadingStats:self];
        }
        
        if (numberOfFinishedOperations > 0 && [self.statsProgressViewDelegate respondsToSelector:@selector(statsViewController:loadingProgressPercentage:)]) {
            CGFloat percentage = (CGFloat)numberOfFinishedOperations / (CGFloat)totalNumberOfOperations;
            [self.statsProgressViewDelegate statsViewController:self loadingProgressPercentage:percentage];
        }
     }
                   andOverallCompletionHandler:^
     {
#ifndef AF_APP_EXTENSIONS
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
         
         [self setupRefreshControl];
         [self.refreshControl endRefreshing];
         
         if ([self.statsProgressViewDelegate respondsToSelector:@selector(statsViewControllerDidEndLoadingStats:)]) {
             [self.statsProgressViewDelegate statsViewControllerDidEndLoadingStats:self];
         }
     }];
}

#pragma mark - Cell configuration private methods

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    switch (statsSection) {
        case StatsSectionGraph:
            switch (indexPath.row) {
                case 0:
                    identifier = StatsTableGraphCellIdentifier;
                    break;
                    
                default:
                    identifier = StatsTableGraphSelectableCellIdentifier;
                    break;
            }
            break;
        case StatsSectionPeriodHeader:
            return StatsTablePeriodHeaderCellIdentifier;
        case StatsSectionEvents:
        {
            StatsGroup *group = (StatsGroup *)[self statsDataForStatsSection:statsSection];
            if (indexPath.row == 0) {
                identifier = StatsTableGroupHeaderCellIdentifier;
            } else if (indexPath.row == 1 && group.numberOfRows == 0) {
                identifier = StatsTableNoResultsCellIdentifier;
            } else if (group.moreItemsExist && indexPath.row == (NSInteger)(group.numberOfRows + StatsTableRowDataOffsetWithoutGroupHeader)) {
                identifier = StatsTableViewAllCellIdentifier;
            } else {
                identifier = StatsTableTwoColumnCellIdentifier;
            }
            break;
        }

        case StatsSectionPosts:
        case StatsSectionReferrers:
        case StatsSectionClicks:
        case StatsSectionCountry:
        case StatsSectionVideos:
        case StatsSectionAuthors:
        case StatsSectionSearchTerms:
        case StatsSectionTagsCategories:
        case StatsSectionPublicize:
        {
            StatsGroup *group = (StatsGroup *)[self statsDataForStatsSection:statsSection];
            if (indexPath.row == 0) {
                identifier = StatsTableGroupHeaderCellIdentifier;
            } else if (indexPath.row == 1 && group.numberOfRows > 0) {
                identifier = StatsTableTwoColumnHeaderCellIdentifier;
            } else if (indexPath.row == 1) {
                identifier = StatsTableNoResultsCellIdentifier;
            } else if (group.moreItemsExist && indexPath.row == (NSInteger)(group.numberOfRows + StatsTableRowDataOffsetStandard)) {
                identifier = StatsTableViewAllCellIdentifier;
            } else {
                identifier = StatsTableTwoColumnCellIdentifier;
            }
            break;
        }
            
        case StatsSectionFollowers:
        {
            StatsGroup *group = [self statsDataForStatsSection:statsSection];
            
            if (indexPath.row == 0) {
                identifier = StatsTableGroupHeaderCellIdentifier;
            } else if (indexPath.row == 1) {
                identifier = StatsTableGroupSelectorCellIdentifier;
            } else if (indexPath.row == 2) {
                if (group.numberOfRows > 0) {
                    identifier = StatsTableGroupTotalsCellIdentifier;
                } else {
                    identifier = StatsTableNoResultsCellIdentifier;
                }
            } else if (indexPath.row == 3) {
                identifier = StatsTableTwoColumnHeaderCellIdentifier;
            } else {
                if (group.moreItemsExist && indexPath.row == (NSInteger)(group.numberOfRows + StatsTableRowDataOffsetWithGroupSelectorAndTotal)) {
                    identifier = StatsTableViewAllCellIdentifier;
                } else {
                    identifier = StatsTableTwoColumnCellIdentifier;
                }
            }
            
            break;
        }

        case StatsSectionComments:
        {
            StatsGroup *group = [self statsDataForStatsSection:statsSection];

            if (indexPath.row == 0) {
                identifier = StatsTableGroupHeaderCellIdentifier;
            } else if (indexPath.row == 1) {
                identifier = StatsTableGroupSelectorCellIdentifier;
            } else if (indexPath.row == 2) {
                if (group.numberOfRows > 0) {
                    identifier = StatsTableTwoColumnHeaderCellIdentifier;
                } else {
                    identifier = StatsTableNoResultsCellIdentifier;
                }
            } else {
                if (group.moreItemsExist && indexPath.row == (NSInteger)(group.numberOfRows + StatsTableRowDataOffsetWithGroupSelector)) {
                    identifier = StatsTableViewAllCellIdentifier;
                } else {
                    identifier = StatsTableTwoColumnCellIdentifier;
                }
            }
            
            break;
        }
        case StatsSectionWebVersion:
            identifier = StatsTableViewWebVersionCellIdentifier;
            break;
        case StatsSectionPostDetailsAveragePerDay:
        case StatsSectionPostDetailsGraph:
        case StatsSectionInsightsAllTime:
        case StatsSectionInsightsMostPopular:
        case StatsSectionInsightsTodaysStats:
        case StatsSectionPostDetailsLoadingIndicator:
        case StatsSectionPostDetailsMonthsYears:
        case StatsSectionPostDetailsRecentWeeks:
            break;
    }

    return identifier;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    
    if (       [cellIdentifier isEqualToString:StatsTableGraphCellIdentifier]) {
        [self configureSectionGraphCell:(StatsStandardBorderedTableViewCell *)cell];
    
    } else if ([cellIdentifier isEqualToString:StatsTablePeriodHeaderCellIdentifier]) {
        [self configurePeriodHeaderCell:cell];
        
    } else if ([cellIdentifier isEqualToString:StatsTableGraphSelectableCellIdentifier]) {
        [self configureSectionGraphSelectableCell:cell forRow:indexPath.row];
        
    } else if ([cellIdentifier isEqualToString:StatsTableGroupHeaderCellIdentifier]) {
        [self configureSectionGroupHeaderCell:(StatsStandardBorderedTableViewCell *)cell
                             withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableTwoColumnHeaderCellIdentifier]) {
        [self configureSectionTwoColumnHeaderCell:(StatsStandardBorderedTableViewCell *)cell
                                 withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableNoResultsCellIdentifier]) {
        [self configureNoResultsCell:cell withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableViewAllCellIdentifier]) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
        label.text = NSLocalizedString(@"View All", @"View All button in stats for larger list");
        
    } else if ([cellIdentifier isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        StatsGroup *group = [self statsDataForStatsSection:statsSection];
        StatsItem *item = [group statsItemForTableViewRow:indexPath.row];
        StatsItem *nextItem = [group statsItemForTableViewRow:indexPath.row + 1];

        [self configureTwoColumnRowCell:cell
                        forStatsSection:statsSection
                          withStatsItem:item
                       andNextStatsItem:nextItem];
    } else if ([cellIdentifier isEqualToString:StatsTableViewWebVersionCellIdentifier]) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
        label.text = NSLocalizedString(@"View Web Version", @"View Web Version button in stats");
        
    }
}


- (void)configureSectionGraphCell:(StatsStandardBorderedTableViewCell *)cell
{
    StatsVisits *visits = [self statsDataForStatsSection:StatsSectionGraph];

    if (![[cell.contentView subviews] containsObject:self.graphViewController.view]) {
        UIView *graphView = self.graphViewController.view;
        [graphView removeFromSuperview];
        graphView.frame = CGRectMake(8.0f, 0.0f, CGRectGetWidth(cell.contentView.bounds) - 16.0f, StatsTableGraphHeight - 1.0);
        graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:graphView];
    }
    
    cell.bottomBorderEnabled = NO;
    
    self.graphViewController.currentSummaryType = self.selectedSummaryType;
    self.graphViewController.visits = visits;
    [self.graphViewController doneSettingProperties];
    [self.graphViewController.collectionView reloadData];
    [self.graphViewController selectGraphBarWithDate:self.selectedDate];
}


- (void)configurePeriodHeaderCell:(UITableViewCell *)cell
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *labelText = @"";
    
    switch (self.selectedPeriodUnit) {
        case StatsPeriodUnitDay:
            dateFormatter.dateFormat = @"MMMM d";
            labelText = [NSString stringWithFormat:NSLocalizedString(@"Stats for %@", @"Stats header for single date"), [dateFormatter stringFromDate:self.selectedDate]];
            break;
        case StatsPeriodUnitWeek:
        {
            dateFormatter.dateFormat = @"MMMM d";
            StatsDateUtilities *dateUtils = [StatsDateUtilities new];
            NSDate *endDate = [dateUtils calculateEndDateForPeriodUnit:self.selectedPeriodUnit withDateWithinPeriod:self.selectedDate];
            labelText = [NSString stringWithFormat:NSLocalizedString(@"Stats for %@ - %@", @"Stats header label for date range"), [dateFormatter stringFromDate:self.selectedDate], [dateFormatter stringFromDate:endDate]];
            break;
        }
        case StatsPeriodUnitMonth:
            dateFormatter.dateFormat = @"MMMM";
            labelText = [NSString stringWithFormat:NSLocalizedString(@"Stats for %@", @"Stats header for single date"), [dateFormatter stringFromDate:self.selectedDate]];
            break;
        case StatsPeriodUnitYear:
            dateFormatter.dateFormat = @"yyyy";
            labelText = [NSString stringWithFormat:NSLocalizedString(@"Stats for %@", @"Stats header for single date"), [dateFormatter stringFromDate:self.selectedDate]];
            break;
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = labelText;
    
    cell.backgroundColor = self.tableView.backgroundColor;
}


- (void)configureSectionGraphSelectableCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    UILabel *iconLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:200];
    UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:300];

    StatsVisits *visits = [self statsDataForStatsSection:StatsSectionGraph];
    StatsSummary *summary = visits.statsDataByDate[self.selectedDate];

    switch (row) {
        case 1: // Views
        {
            iconLabel.text = @"";
            textLabel.text = [NSLocalizedString(@"Views", @"") uppercaseStringWithLocale:[NSLocale currentLocale]];
            valueLabel.text = summary.views;
            break;
        }
            
        case 2: // Visitors
        {
            iconLabel.text = @"";
            textLabel.text = [NSLocalizedString(@"Visitors", @"") uppercaseStringWithLocale:[NSLocale currentLocale]];
            valueLabel.text = summary.visitors;
            break;
        }
            
        case 3: // Likes
        {
            iconLabel.text = @"";
            textLabel.text = [NSLocalizedString(@"Likes", @"") uppercaseStringWithLocale:[NSLocale currentLocale]];
            valueLabel.text = summary.likes;
            break;
        }
            
        case 4: // Comments
        {
            iconLabel.text = @"";
            textLabel.text = [NSLocalizedString(@"Comments", @"") uppercaseStringWithLocale:[NSLocale currentLocale]];
            valueLabel.text = summary.comments;
            break;
        }
            
        default:
            break;
    }
}


- (void)configureSectionGroupHeaderCell:(StatsStandardBorderedTableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
    NSString *headerText = statsGroup.groupTitle;
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = headerText;
    label.textColor = [WPStyleGuide greyDarken10];

    cell.bottomBorderEnabled = NO;
}


- (void)configureSectionTwoColumnHeaderCell:(StatsStandardBorderedTableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
    StatsItem *statsItem = [statsGroup statsItemForTableViewRow:2];
    
    NSString *leftText = statsGroup.titlePrimary;
    NSString *rightText = statsGroup.titleSecondary;
    
    // Hide the bottom border if the first row is expanded
    cell.bottomBorderEnabled = !statsItem.isExpanded;
    
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
}


- (void)configureNoResultsCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    NSString *text;
    id data = [self statsDataForStatsSection:statsSection];
    
    if (!data) {
        text = NSLocalizedString(@"Waiting for data...", @"Message displayed in stats while waiting for remote operations to finish.");
    } else if ([data errorWhileRetrieving] == YES) {
        text = NSLocalizedString(@"An error occurred while retrieving data. Retry in a bit!", @"Error message in section when data failed.");
    } else {
        switch (statsSection) {
            case StatsSectionClicks:
                text = NSLocalizedString(@"No clicks recorded", @"");
                break;
            case StatsSectionComments:
                text = NSLocalizedString(@"No comments posted", @"");
                break;
            case StatsSectionCountry:
                text = NSLocalizedString(@"No countries recorded", @"");
                break;
            case StatsSectionEvents:
                text = NSLocalizedString(@"No items published during this timeframe", @"");
                break;
            case StatsSectionFollowers:
                text = NSLocalizedString(@"No followers", @"");
                break;
            case StatsSectionAuthors:
            case StatsSectionPosts:
                text = NSLocalizedString(@"No posts or pages viewed", @"");
                break;
            case StatsSectionPublicize:
                text = NSLocalizedString(@"No publicize followers recorded", @"");
                break;
            case StatsSectionReferrers:
                text = NSLocalizedString(@"No referrers recorded", @"");
                break;
            case StatsSectionSearchTerms:
                text = NSLocalizedString(@"No search terms recorded", @"");
                break;
            case StatsSectionTagsCategories:
                text = NSLocalizedString(@"No tagged posts or pages viewed", @"");
                break;
            case StatsSectionVideos:
                text = NSLocalizedString(@"No videos played", @"");
                break;
            case StatsSectionGraph:
            case StatsSectionInsightsAllTime:
            case StatsSectionInsightsMostPopular:
            case StatsSectionInsightsTodaysStats:
            case StatsSectionPeriodHeader:
            case StatsSectionWebVersion:
            case StatsSectionPostDetailsAveragePerDay:
            case StatsSectionPostDetailsGraph:
            case StatsSectionPostDetailsLoadingIndicator:
            case StatsSectionPostDetailsMonthsYears:
            case StatsSectionPostDetailsRecentWeeks:
                break;
        }
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = text;
}


- (void)configureTwoColumnRowCell:(UITableViewCell *)cell
                  forStatsSection:(StatsSection)statsSection
                    withStatsItem:(StatsItem *)statsItem
                 andNextStatsItem:(StatsItem *)nextStatsItem
{
    BOOL showCircularIcon = (statsSection == StatsSectionComments || statsSection == StatsSectionFollowers || statsSection == StatsSectionAuthors);
    
    StatsTwoColumnTableViewCellSelectType selectType = StatsTwoColumnTableViewCellSelectTypeDetail;
    if (statsItem.actions.count > 0 && (statsSection == StatsSectionReferrers || statsSection == StatsSectionClicks)) {
        selectType = StatsTwoColumnTableViewCellSelectTypeURL;
    } else if (statsSection == StatsSectionTagsCategories) {
        if ([statsItem.alternateIconValue isEqualToString:@"category"]) {
            selectType = StatsTwoColumnTableViewCellSelectTypeCategory;
        } else if ([statsItem.alternateIconValue isEqualToString:@"tag"]) {
            selectType = StatsTwoColumnTableViewCellSelectTypeTag;
        }
    }

    StatsTwoColumnTableViewCell *statsCell = (StatsTwoColumnTableViewCell *)cell;
    statsCell.leftText = statsItem.label;
    statsCell.rightText = statsItem.value;
    statsCell.imageURL = statsItem.iconURL;
    statsCell.showCircularIcon = showCircularIcon;
    statsCell.indentLevel = statsItem.depth;
    statsCell.indentable = NO;
    statsCell.expandable = statsItem.children.count > 0;
    statsCell.expanded = statsItem.expanded;
    statsCell.selectable = statsItem.actions.count > 0 || statsItem.children.count > 0;
    statsCell.selectType = selectType;
    statsCell.bottomBorderEnabled = !(nextStatsItem.isExpanded);
    
    [statsCell doneSettingProperties];
}

#pragma mark - Row and section calculation methods

- (StatsSection)statsSectionForTableViewSection:(NSInteger)section
{
    return (StatsSection)[self.sections[(NSUInteger)section] integerValue];
}


- (id)statsDataForStatsSection:(StatsSection)statsSection
{
    id data = self.sectionData[@(statsSection)];
    
    return data;
}


- (void)wipeDataAndSeedGroups
{
    if (self.sectionData) {
        [self.sectionData removeAllObjects];
    } else {
        self.sectionData = [NSMutableDictionary new];
    }
    
    self.sectionData[@(StatsSectionComments)] = [NSMutableDictionary new];
    self.sectionData[@(StatsSectionFollowers)] = [NSMutableDictionary new];

    for (NSNumber *statsSectionNumber in self.sections) {
        StatsSection statsSection = (StatsSection)statsSectionNumber.integerValue;
        if (statsSection != StatsSectionGraph) {
            StatsGroup *group = [[StatsGroup alloc] initWithStatsSection:statsSection andStatsSubSection:StatsSubSectionNone];
            self.sectionData[statsSectionNumber] = group;
        }
    }
}


- (void)setupRefreshControl
{
    if (self.refreshControl) {
        return;
    }
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshCurrentStats:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}


// Resets self.selected date to an NSDate with device local timezone but representing what today is
// for the site, not the device
- (void)resetDateToTodayForSite
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = self.statsService.siteTimeZone;
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDate *date = [calendar dateFromComponents:components];
    self.selectedDate = date;
}

- (void)trackViewControllerAnalytics
{
    WPAnalyticsStat stat;
    
    switch (self.selectedPeriodUnit) {
        case StatsPeriodUnitDay:
            stat = WPAnalyticsStatStatsPeriodDaysAccessed;
            break;
        case StatsPeriodUnitWeek:
            stat = WPAnalyticsStatStatsPeriodWeeksAccessed;
            break;
        case StatsPeriodUnitMonth:
            stat = WPAnalyticsStatStatsPeriodMonthsAccessed;
            break;
        case StatsPeriodUnitYear:
            stat = WPAnalyticsStatStatsPeriodYearsAccessed;
            break;
    }
    
    [WPAnalytics track:stat];
}


@end

#import "StatsTableViewController.h"
#import "WPStatsGraphViewController.h"
#import "WPStatsService.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import <WPFontManager.h>
#import "WPStyleGuide+Stats.h"
#import <WPImageSource.h>
#import "StatsTableSectionHeaderView.h"
#import "StatsDateUtilities.h"
#import "StatsTwoColumnTableViewCell.h"
#import "StatsViewAllTableViewController.h"
#import "StatsSection.h"

static CGFloat const StatsTableGraphHeight = 185.0f;
static CGFloat const StatsTableNoResultsHeight = 100.0f;
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

@interface StatsTableViewController () <WPStatsGraphViewControllerDelegate>

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *subSections;
@property (nonatomic, strong) NSMutableDictionary *sectionData;
@property (nonatomic, strong) WPStatsGraphViewController *graphViewController;
@property (nonatomic, strong) WPStatsService *statsService;
@property (nonatomic, assign) StatsPeriodUnit selectedPeriodUnit;
@property (nonatomic, assign) StatsSummaryType selectedSummaryType;
@property (nonatomic, strong) NSMutableDictionary *selectedSubsections;
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation StatsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[StatsTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    // Force load fonts from bundle
    [WPFontManager openSansBoldFontOfSize:1.0f];
    [WPFontManager openSansRegularFontOfSize:1.0f];

    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshCurrentStats:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.sections =     @[ @(StatsSectionGraph),
                           @(StatsSectionPeriodHeader),
                           @(StatsSectionPosts),
                           @(StatsSectionReferrers),
                           @(StatsSectionClicks),
                           @(StatsSectionCountry),
                           @(StatsSectionVideos),
                           @(StatsSectionComments),
                           @(StatsSectionTagsCategories),
                           @(StatsSectionFollowers),
                           @(StatsSectionPublicize)];
    self.subSections =  @{ @(StatsSectionComments) : @[@(StatsSubSectionCommentsByAuthor), @(StatsSubSectionCommentsByPosts)],
                           @(StatsSectionFollowers) : @[@(StatsSubSectionFollowersDotCom), @(StatsSubSectionFollowersEmail)]};
    self.selectedSubsections = [@{ @(StatsSectionComments) : @(StatsSubSectionCommentsByAuthor),
                                   @(StatsSectionFollowers) : @(StatsSubSectionFollowersDotCom)} mutableCopy];
    
    [self wipeDataAndSeedGroups];
    
    self.graphViewController = [WPStatsGraphViewController new];
    self.selectedDate = [NSDate date];
    self.selectedPeriodUnit = StatsPeriodUnitDay;
    self.selectedSummaryType = StatsSummaryTypeViews;
    self.graphViewController.allowDeselection = NO;
    self.graphViewController.graphDelegate = self;
    [self addChildViewController:self.graphViewController];
    [self.graphViewController didMoveToParentViewController:self];
    
    NSTimeInterval fiveMinutes = 60 * 5;
    self.statsService = [[WPStatsService alloc] initWithSiteId:self.siteID siteTimeZone:self.siteTimeZone oauth2Token:self.oauth2Token andCacheExpirationInterval:fiveMinutes];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self retrieveStatsSkipGraph:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self retrieveStatsSkipGraph:NO];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    StatsSection statsSection = [self statsSectionForTableViewSection:section];
    id data = [self statsDataForStatsSection:statsSection];
    
    switch (statsSection) {
        case StatsSectionGraph:
            return 5;
        case StatsSectionPeriodHeader:
            return 1;
            
        // TODO :: Pull offset from StatsGroup
        default:
        {
            StatsGroup *group = (StatsGroup *)data;
            NSUInteger count = group.numberOfRows;
            
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
        
        if (statsItem.children.count > 0) {
            BOOL insert = !statsItem.isExpanded;
            NSInteger numberOfRowsBefore = statsItem.numberOfRows - 1;
            statsItem.expanded = !statsItem.isExpanded;
            NSInteger numberOfRowsAfter = statsItem.numberOfRows - 1;
            
            NSMutableArray *indexPaths = [NSMutableArray new];
            
            NSInteger numberOfRows = insert ? numberOfRowsAfter : numberOfRowsBefore;
            for (NSInteger row = 1; row <= numberOfRows; ++row) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:(row + indexPath.row) inSection:indexPath.section]];
            }
            
            [self.tableView beginUpdates];
            
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
                        [[UIApplication sharedApplication] openURL:action.url];
                    }
                    break;
                }
            }
        }
        
    }
}


#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    [super prepareForSegue:segue sender:sender];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    StatsSubSection statsSubSection = [self statsSubSectionForStatsSection:statsSection];
    
    if ([segue.destinationViewController isKindOfClass:[StatsViewAllTableViewController class]]) {
        StatsViewAllTableViewController *viewAllVC = (StatsViewAllTableViewController *)segue.destinationViewController;
        viewAllVC.selectedDate = self.selectedDate;
        viewAllVC.periodUnit = self.selectedPeriodUnit;
        viewAllVC.statsSection = statsSection;
        viewAllVC.statsSubSection = statsSubSection;
        viewAllVC.statsService = self.statsService;
    }
}


#pragma mark - WPStatsGraphViewControllerDelegate methods


- (void)statsGraphViewController:(WPStatsGraphViewController *)controller didSelectDate:(NSDate *)date
{
    self.selectedDate = date;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self.sections indexOfObject:@(StatsSectionPeriodHeader)]];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    // Reset the data (except the graph) and refresh
    id graphData = self.sectionData[@(StatsSectionGraph)];
    [self wipeDataAndSeedGroups];
    self.sectionData[@(StatsSectionGraph)] = graphData;

    [self.tableView reloadData];
    
    NSUInteger section = [self.sections indexOfObject:@(StatsSectionGraph)];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.selectedSummaryType + 1) inSection:section];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self retrieveStatsSkipGraph:YES];
}


#pragma mark - Stats retrieval methods


- (IBAction)refreshCurrentStats:(UIRefreshControl *)sender
{
    self.selectedDate = [NSDate date];
    [self.statsService expireAllItemsInCache];
    [self retrieveStatsSkipGraph:NO];
}


- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control
{
    StatsPeriodUnit unit = (StatsPeriodUnit)control.selectedSegmentIndex;
    self.selectedPeriodUnit = unit;
    self.selectedDate = [NSDate date];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self.sections indexOfObject:@(StatsSectionPeriodHeader)]];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

    [self wipeDataAndSeedGroups];
    [self.tableView reloadData];
    
    [self retrieveStatsSkipGraph:NO];
}

- (IBAction)sectionGroupSelectorDidChange:(UISegmentedControl *)control
{
    StatsSection statsSection = (StatsSection)control.superview.tag;
    NSInteger section = [self.sections indexOfObject:@(statsSection)];
    
    NSInteger oldSectionCount = [self tableView:self.tableView numberOfRowsInSection:section];
    StatsSubSection subSection;
    
    switch (statsSection) {
        case StatsSectionComments:
            subSection = control.selectedSegmentIndex == 0 ? StatsSubSectionCommentsByAuthor : StatsSubSectionCommentsByPosts;
            break;
        case StatsSectionFollowers:
            subSection = control.selectedSegmentIndex == 0 ? StatsSubSectionFollowersDotCom : StatsSubSectionFollowersEmail;
            break;
        default:
            break;
    }
    
    self.selectedSubsections[@(section)] = @(subSection);
    NSInteger newSectionCount = [self tableView:self.tableView numberOfRowsInSection:section];
    
    NSUInteger sectionNumber = [self.sections indexOfObject:@(statsSection)];
    NSMutableArray *oldIndexPaths = [NSMutableArray new];
    NSMutableArray *newIndexPaths = [NSMutableArray new];
    
    for (NSInteger row = StatsTableRowDataOffsetWithGroupSelector; row < oldSectionCount; ++row) {
        [oldIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:sectionNumber]];
    }
    for (NSInteger row = StatsTableRowDataOffsetWithGroupSelector; row < newSectionCount; ++row) {
        [newIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:sectionNumber]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
}

- (void)retrieveStatsSkipGraph:(BOOL)skipGraph
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionGraph)];
         NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.selectedSummaryType + 1) inSection:sectionNumber];
         [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
     }
                        eventsCompletionHandler:nil
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
                commentsAuthorCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetWithGroupSelector;
         self.sectionData[@(StatsSectionComments)][@(StatsSubSectionCommentsByAuthor)] = group;
         
         if ([self.selectedSubsections[@(StatsSectionComments)] isEqualToNumber:@(StatsSubSectionCommentsByAuthor)]) {
             [self.tableView beginUpdates];
             
             NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionComments)];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             [self.tableView endUpdates];
         }
     }
                commentsPostsCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetWithGroupSelector;
         self.sectionData[@(StatsSectionComments)][@(StatsSubSectionCommentsByPosts)] = group;
         
         if ([self.selectedSubsections[@(StatsSectionComments)] isEqualToNumber:@(StatsSubSectionCommentsByPosts)]) {
             [self.tableView beginUpdates];
             
             NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionComments)];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             [self.tableView endUpdates];
         }
     }
                tagsCategoriesCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionTagsCategories)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionTagsCategories)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
               followersDotComCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetWithGroupSelectorAndTotal;
         self.sectionData[@(StatsSectionFollowers)][@(StatsSubSectionFollowersDotCom)] = group;
         
         if ([self.selectedSubsections[@(StatsSectionFollowers)] isEqualToNumber:@(StatsSubSectionFollowersDotCom)]) {
             [self.tableView beginUpdates];
             
             NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionFollowers)];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             [self.tableView endUpdates];
         }
     }
                followersEmailCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetWithGroupSelectorAndTotal;
         self.sectionData[@(StatsSectionFollowers)][@(StatsSubSectionFollowersEmail)] = group;

         if ([self.selectedSubsections[@(StatsSectionFollowers)] isEqualToNumber:@(StatsSubSectionFollowersEmail)]) {
             [self.tableView beginUpdates];
             
             NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionFollowers)];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             [self.tableView endUpdates];
         }
     }
                     publicizeCompletionHandler:^(StatsGroup *group, NSError *error)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionPublicize)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionPublicize)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                    andOverallCompletionHandler:^
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         [self.refreshControl endRefreshing];
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
            } else if (group.moreItemsExist && indexPath.row == (group.numberOfRows + StatsTableRowDataOffsetWithoutGroupHeader)) {
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
            } else if (group.moreItemsExist && indexPath.row == (group.numberOfRows + StatsTableRowDataOffsetStandard)) {
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
                if (group.moreItemsExist && indexPath.row == (group.numberOfRows + StatsTableRowDataOffsetWithGroupSelectorAndTotal)) {
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
                if (group.moreItemsExist && indexPath.row == (group.numberOfRows + StatsTableRowDataOffsetWithGroupSelector)) {
                    identifier = StatsTableViewAllCellIdentifier;
                } else {
                    identifier = StatsTableTwoColumnCellIdentifier;
                }
            }
            
            break;
        }
    }
    
    return identifier;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    
    if (       [cellIdentifier isEqualToString:StatsTableGraphCellIdentifier]) {
        [self configureSectionGraphCell:cell];
    
    } else if ([cellIdentifier isEqualToString:StatsTablePeriodHeaderCellIdentifier]) {
        [self configurePeriodHeaderCell:cell];
        
    } else if ([cellIdentifier isEqualToString:StatsTableGraphSelectableCellIdentifier]) {
        [self configureSectionGraphSelectableCell:cell forRow:indexPath.row];
        
    } else if ([cellIdentifier isEqualToString:StatsTableGroupHeaderCellIdentifier]) {
        [self configureSectionGroupHeaderCell:cell
                             withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableGroupSelectorCellIdentifier]) {
        [self configureSectionGroupSelectorCell:cell withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableTwoColumnHeaderCellIdentifier]) {
        [self configureSectionTwoColumnHeaderCell:cell
                                 withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableGroupTotalsCellIdentifier]) {
        StatsGroup *group = [self statsDataForStatsSection:statsSection];
        [self configureSectionGroupTotalCell:cell withStatsSection:statsSection andTotal:group.totalCount];
        
    } else if ([cellIdentifier isEqualToString:StatsTableNoResultsCellIdentifier]) {
        [self configureNoResultsCell:cell withStatsSection:statsSection];
        
    } else if ([cellIdentifier isEqualToString:StatsTableViewAllCellIdentifier]) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
        label.text = NSLocalizedString(@"View All", @"View All button in stats for larger list");
        
    } else if ([cellIdentifier isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        StatsGroup *group = [self statsDataForStatsSection:statsSection];
        StatsItem *item = [group statsItemForTableViewRow:indexPath.row];
        
        [self configureTwoColumnRowCell:cell
                           withLeftText:item.label
                              rightText:item.value
                            andImageURL:item.iconURL
                            indentLevel:item.depth
                             selectable:item.actions.count > 0 || item.children.count > 0];
    }
}


- (void)configureSectionGraphCell:(UITableViewCell *)cell
{
    StatsVisits *visits = [self statsDataForStatsSection:StatsSectionGraph];

    if (![[cell.contentView subviews] containsObject:self.graphViewController.view]) {
        UIView *graphView = self.graphViewController.view;
        [graphView removeFromSuperview];
        graphView.frame = CGRectMake(8.0f, 0.0f, CGRectGetWidth(cell.contentView.bounds) - 16.0f, StatsTableGraphHeight - 1.0);
        graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:graphView];
    }
    
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


- (void)configureSectionGroupHeaderCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
    NSString *headerText = statsGroup.groupTitle;
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = headerText;
}


- (void)configureSectionTwoColumnHeaderCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
    NSString *leftText = statsGroup.titlePrimary;
    NSString *rightText = statsGroup.titleSecondary;
    
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
}


- (void)configureSectionGroupTotalCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection andTotal:(NSString *)total
{
    NSString *title;
    StatsSubSection selectedSubsection = [self statsSubSectionForStatsSection:statsSection];
    
    switch (selectedSubsection) {
        case StatsSubSectionFollowersDotCom:
            title = [NSString stringWithFormat:NSLocalizedString(@"Total WordPress.com Followers: %@", @"Label of Total count of WordPress.com followers with value"), total];
            break;
        case StatsSubSectionFollowersEmail:
            title = [NSString stringWithFormat:NSLocalizedString(@"Total Email Followers: %@", @"Label of Total count of email followers with value"), total];
            break;
        default:
            break;
    }

    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = title;
}


- (void)configureSectionGroupSelectorCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    NSArray *titles;
    NSInteger selectedIndex = 0;
    StatsSubSection selectedSubsection = [self statsSubSectionForStatsSection:statsSection];
    
    switch (statsSection) {
        case StatsSectionComments:
            titles = @[NSLocalizedString(@"By Authors", @"Authors segmented control for stats"),
                       NSLocalizedString(@"By Posts & Pages", @"Posts & Pages segmented control for stats")];
            selectedIndex = selectedSubsection == StatsSubSectionCommentsByAuthor ? 0 : 1;
            break;
        case StatsSectionFollowers:
            titles = @[NSLocalizedString(@"WordPress.com", @"WordPress.com segmented control for stats"),
                       NSLocalizedString(@"Email", @"Email segmented control for stats")];
            selectedIndex = selectedSubsection == StatsSubSectionFollowersDotCom ? 0 : 1;
            break;
        default:
            break;
    }
    
    UISegmentedControl *control = (UISegmentedControl *)[cell.contentView viewWithTag:100];
    cell.contentView.tag = statsSection;
    
    [control removeAllSegments];
    
    for (NSString *title in [titles reverseObjectEnumerator]) {
        [control insertSegmentWithTitle:title atIndex:0 animated:NO];
    }
    
    control.selectedSegmentIndex = selectedIndex;
}


- (void)configureNoResultsCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    NSString *text;
    id data = [self statsDataForStatsSection:statsSection];
    
    if (!data) {
        text = NSLocalizedString(@"Waiting for data...", @"");
    } else if ([data errorWhileRetrieving] == YES) {
        text = NSLocalizedString(@"An error occurred while retrieving data. Retry in a bit!", @"Error message in section when data failed.");
    } else {
        switch (statsSection) {
            case StatsSectionClicks:
                text = NSLocalizedString(@"No clicks recorded", @"");
                break;
            case StatsSectionEvents:
                text = NSLocalizedString(@"No items published during this timeframe", @"");
                break;
            case StatsSectionPublicize:
                text = NSLocalizedString(@"No publicize followers recorded", @"");
                break;
            case StatsSectionReferrers:
                text = NSLocalizedString(@"No referrers recorded", @"");
                break;
            case StatsSectionTagsCategories:
                text = NSLocalizedString(@"No tagged posts or pages viewed", @"");
                break;
            case StatsSectionVideos:
                text = NSLocalizedString(@"No videos played", @"");
                break;
            default:
                text = NSLocalizedString(@"No posts or pages viewed", @"");
                break;
        }
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = text;
}


- (void)configureTwoColumnRowCell:(UITableViewCell *)cell
                     withLeftText:(NSString *)leftText
                        rightText:(NSString *)rightText
                      andImageURL:(NSURL *)imageURL
                      indentLevel:(NSUInteger)indentLevel
                       selectable:(BOOL)selectable
{
    StatsTwoColumnTableViewCell *statsCell = (StatsTwoColumnTableViewCell *)cell;
    statsCell.leftText = leftText;
    statsCell.rightText = rightText;
    statsCell.imageURL = imageURL;
    statsCell.indentLevel = indentLevel;
    statsCell.selectable = selectable;
    [statsCell doneSettingProperties];
}

#pragma mark - Row and section calculation methods

- (StatsSection)statsSectionForTableViewSection:(NSInteger)section
{
    return (StatsSection)[self.sections[section] integerValue];
}


- (StatsSubSection)statsSubSectionForStatsSection:(StatsSection)statsSection
{
    NSNumber *subSectionValue = self.selectedSubsections[@(statsSection)];
    
    if (!subSectionValue) {
        return StatsSubSectionNone;
    }
    
    return (StatsSubSection)[subSectionValue integerValue];
}


- (id)statsDataForStatsSection:(StatsSection)statsSection
{
    id data;
    
    if ( statsSection == StatsSectionComments || statsSection == StatsSectionFollowers) {
        StatsSubSection selectedSubsection = [self statsSubSectionForStatsSection:statsSection];
        data = self.sectionData[@(statsSection)][@(selectedSubsection)];
    } else {
        data = self.sectionData[@(statsSection)];
    }
    
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
        StatsSubSection statsSubSection = StatsSubSectionNone;
        
        if ([self.subSections objectForKey:statsSectionNumber] != nil) {
            for (NSNumber *statsSubSectionNumber in self.subSections) {
                statsSubSection = (StatsSubSection)statsSubSectionNumber.integerValue;
                StatsGroup *group = [[StatsGroup alloc] initWithStatsSection:statsSection andStatsSubSection:statsSubSection];
                self.sectionData[statsSectionNumber][statsSubSectionNumber] = group;
            }
        } else {
            
        }
    }
}

@end

#import "StatsTableViewController.h"
#import "WPStatsGraphViewController.h"
#import "WPStatsService.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import <WPFontManager.h>
#import "WPStyleGuide+Stats.h"
#import <WPImageSource.h>

typedef NS_ENUM(NSInteger, StatsSection) {
    StatsSectionPeriodSelector,
    StatsSectionGraph,
    StatsSectionPosts,
    StatsSectionReferrers,
    StatsSectionClicks,
    StatsSectionCountry,
    StatsSectionVideos,
    StatsSectionComments,
    StatsSectionTagsCategories,
    StatsSectionFollowers,
    StatsSectionPublicize
};

typedef NS_ENUM(NSInteger, StatsSubSection) {
    StatsSubSectionCommentsByAuthor,
    StatsSubSectionCommentsByPosts,
    StatsSubSectionFollowersDotCom,
    StatsSubSectionFollowersEmail
};

static CGFloat const StatsTableGraphHeight = 175.0f;
static CGFloat const StatsTableNoResultsHeight = 100.0f;
static CGFloat const StatsTableSelectableCellHeight = 35.0f;
static NSInteger const StatsTableRowDataOffsetStandard = 2;
static NSInteger const StatsTableRowDataOffsetWithGroupSelector = 3;
static NSString *const StatsTablePeriodSelectorCellIdentifier = @"PeriodSelector";
static NSString *const StatsTableGroupHeaderCellIdentifier = @"GroupHeader";
static NSString *const StatsTableGroupSelectorCellIdentifier = @"GroupSelector";
static NSString *const StatsTableTwoColumnHeaderCellIdentifier = @"TwoColumnHeader";
static NSString *const StatsTableTwoColumnCellIdentifier = @"TwoColumnRow";
static NSString *const StatsTableGraphSelectableCellIdentifier = @"SelectableRow";
static NSString *const StatsTableViewAllCellIdentifier = @"MoreRow";
static NSString *const StatsTableGraphCellIdentifier = @"GraphRow";
static NSString *const StatsTableNoResultsCellIdentifier = @"NoResultsRow";


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

@property (assign, getter=isSyncing) BOOL syncing;

@end

@implementation StatsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Force load fonts from bundle
    [WPFontManager openSansBoldFontOfSize:1.0f];
    [WPFontManager openSansRegularFontOfSize:1.0f];

    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshCurrentStats:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.sections =     @[ @(StatsSectionPeriodSelector),
                           @(StatsSectionGraph),
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
    
    self.sectionData = [NSMutableDictionary new];
    self.sectionData[@(StatsSectionComments)] = [NSMutableDictionary new];
    self.sectionData[@(StatsSectionFollowers)] = [NSMutableDictionary new];
    
    self.graphViewController = [WPStatsGraphViewController new];
    self.selectedDate = [NSDate date];
    self.selectedPeriodUnit = StatsPeriodUnitDay;
    self.selectedSummaryType = StatsSummaryTypeViews;
    self.graphViewController.allowDeselection = NO;
    self.graphViewController.graphDelegate = self;
    
    self.statsService = [[WPStatsService alloc] initWithSiteId:self.siteID siteTimeZone:self.siteTimeZone andOAuth2Token:self.oauth2Token];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self retrieveStatsSkipGraph:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    StatsSection statsSection = [self statsSectionForTableViewSection:section];
    id data = [self statsDataForStatsSection:statsSection];
    
    switch (statsSection) {
        case StatsSectionPeriodSelector:
            return 1;
        case StatsSectionGraph: {
            BOOL hasData = data != nil;
            return hasData ? 5 : 1;
        }
        case StatsSectionPosts:
        case StatsSectionReferrers:
        case StatsSectionClicks:
        case StatsSectionCountry:
        case StatsSectionVideos:
        case StatsSectionPublicize:
        case StatsSectionTagsCategories:
        case StatsSectionComments:
        case StatsSectionFollowers:
        {
            StatsGroup *group = (StatsGroup *)data;
            NSUInteger count = group.numberOfRows + StatsTableRowDataOffsetStandard;
            
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
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];

    if ([cellIdentifier isEqualToString:StatsTableGraphCellIdentifier]) {
        return StatsTableGraphHeight;
    } else if ([cellIdentifier isEqualToString:StatsTableNoResultsCellIdentifier]) {
        return StatsTableNoResultsHeight;
    } else if ([cellIdentifier isEqualToString:StatsTableGraphSelectableCellIdentifier]) {
        return StatsTableSelectableCellHeight;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    if (statsSection == StatsSectionGraph && indexPath.row > 0) {
        if (self.isSyncing) {
            return nil;
        }
        
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
        
        BOOL hasChildItems = item.children.count;
        return hasChildItems ? indexPath : nil;
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
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableViewAllCellIdentifier]) {
        // Placeholder for full screen details
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        // Placeholder for full screen details
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        StatsGroup *statsGroup = [self statsDataForStatsSection:statsSection];
        StatsItem *statsItem = [statsGroup statsItemForTableViewRow:indexPath.row];
        
        NSInteger oldRowCount = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
        statsItem.expanded = !statsItem.isExpanded;
        NSInteger newRowCount = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
        
        NSMutableArray *oldIndexPaths = [NSMutableArray new];
        NSMutableArray *newIndexPaths = [NSMutableArray new];
        
        for (NSInteger x = indexPath.row + 1; x < oldRowCount; ++x) {
            [oldIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:indexPath.section]];
        }
        for (NSInteger x = indexPath.row + 1; x < newRowCount; ++x) {
            [newIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:indexPath.section]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
    }
}


#pragma mark - WPStatsGraphViewControllerDelegate methods

- (void)statsGraphViewController:(WPStatsGraphViewController *)controller didSelectDate:(NSDate *)date
{
    self.selectedDate = date;
    
    NSUInteger section = [self.sections indexOfObject:@(StatsSectionGraph)];
    NSArray *indexPaths = @[[NSIndexPath indexPathForItem:1 inSection:section],
                            [NSIndexPath indexPathForItem:2 inSection:section],
                            [NSIndexPath indexPathForItem:3 inSection:section],
                            [NSIndexPath indexPathForItem:4 inSection:section]];

    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    // Reset the data (except the graph) and refresh
    id graphData = self.sectionData[@(StatsSectionGraph)];
    [self.sectionData removeAllObjects];
    self.sectionData[@(StatsSectionGraph)] = graphData;
    self.sectionData[@(StatsSectionComments)] = [NSMutableDictionary new];
    self.sectionData[@(StatsSectionFollowers)] = [NSMutableDictionary new];

    [self.tableView beginUpdates];

    NSRange range = NSMakeRange([self.sections indexOfObject:@(StatsSectionGraph)] + 1, self.sections.count - 2);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];

    [self.tableView endUpdates];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.selectedSummaryType + 1) inSection:section];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    
    [self retrieveStatsSkipGraph:YES];
}


#pragma mark - Stats retrieval methods

- (IBAction)refreshCurrentStats:(id)sender
{
    [self retrieveStatsSkipGraph:NO];
}

- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control
{
    StatsPeriodUnit unit = (StatsPeriodUnit)control.selectedSegmentIndex;
    
    if (self.isSyncing) {
        control.selectedSegmentIndex = self.selectedPeriodUnit;
        return;
    }
    
    self.selectedPeriodUnit = unit;
    [self.sectionData removeAllObjects];
    self.sectionData[@(StatsSectionComments)] = [NSMutableDictionary new];
    self.sectionData[@(StatsSectionFollowers)] = [NSMutableDictionary new];
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
    self.syncing = YES;
    
    [self.statsService retrieveAllStatsForDates:@[self.selectedDate]
                                        andUnit:self.selectedPeriodUnit
                    withVisitsCompletionHandler:^(StatsVisits *visits)
     {
         if (skipGraph) {
             return;
         }
         
         self.sectionData[@(StatsSectionGraph)] = visits;
         self.selectedDate = ((StatsSummary *)visits.statsData.lastObject).date;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionGraph)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
         
         NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.selectedSummaryType + 1) inSection:sectionNumber];
         [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
     }
                         postsCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionPosts)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionPosts)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                     referrersCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionReferrers)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionReferrers)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                        clicksCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionClicks)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionClicks)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                       countryCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionCountry)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionCountry)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                        videosCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionVideos)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionVideos)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                commentsAuthorCompletionHandler:^(StatsGroup *group)
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
                commentsPostsCompletionHandler:^(StatsGroup *group)
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
                tagsCategoriesCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetStandard;
         self.sectionData[@(StatsSectionTagsCategories)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionTagsCategories)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
               followersDotComCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetWithGroupSelector;
         self.sectionData[@(StatsSectionFollowers)][@(StatsSubSectionFollowersDotCom)] = group;
         
         if ([self.selectedSubsections[@(StatsSectionFollowers)] isEqualToNumber:@(StatsSubSectionFollowersDotCom)]) {
             [self.tableView beginUpdates];
             
             NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionFollowers)];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             [self.tableView endUpdates];
         }
     }
                followersEmailCompletionHandler:^(StatsGroup *group)
     {
         group.offsetRows = StatsTableRowDataOffsetWithGroupSelector;
         self.sectionData[@(StatsSectionFollowers)][@(StatsSubSectionFollowersEmail)] = group;

         if ([self.selectedSubsections[@(StatsSectionFollowers)] isEqualToNumber:@(StatsSubSectionFollowersEmail)]) {
             [self.tableView beginUpdates];
             
             NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionFollowers)];
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
             [self.tableView endUpdates];
         }
     }
                     publicizeCompletionHandler:^(StatsGroup *group)
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
         self.syncing = NO;
         [self.refreshControl endRefreshing];
     }
                          overallFailureHandler:^(NSError *error)
     {
         DDLogError(@"Error when syncing: %@", error);
     }];
}

#pragma mark - Cell configuration private methods

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    switch (statsSection) {
        case StatsSectionPeriodSelector:
            identifier = StatsTablePeriodSelectorCellIdentifier;
            break;
        case StatsSectionGraph: {
            switch (indexPath.row) {
                case 0:
                    if ([self statsDataForStatsSection:statsSection] != nil) {
                        identifier = StatsTableGraphCellIdentifier;
                    } else {
                        identifier = StatsTableNoResultsCellIdentifier;
                    }
                    break;
                    
                default:
                    identifier = StatsTableGraphSelectableCellIdentifier;
                    break;
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
            
        case StatsSectionComments:
        case StatsSectionFollowers:
        {
            StatsGroup *group = [self statsDataForStatsSection:statsSection];

            switch (indexPath.row) {
                case 0:
                    identifier = StatsTableGroupHeaderCellIdentifier;
                    break;
                case 1:
                    identifier = StatsTableGroupSelectorCellIdentifier;
                    break;
                case 2:
                {
                    if (group.numberOfRows > 0) {
                        identifier = StatsTableTwoColumnHeaderCellIdentifier;
                    } else {
                        identifier = StatsTableNoResultsCellIdentifier;
                    }
                    break;
                }
                default:
                    if (group.moreItemsExist && indexPath.row == (group.numberOfRows + StatsTableRowDataOffsetWithGroupSelector)) {
                        identifier = StatsTableViewAllCellIdentifier;
                    } else {
                        identifier = StatsTableTwoColumnCellIdentifier;
                    }
                    break;
            }
            break;
        }
    }
    
    return identifier;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    if (statsSection == StatsSectionGraph) {
        [self configureSectionGraphCell:cell forRow:indexPath.row];
    } else if (statsSection != StatsSectionPeriodSelector) {
        [self configureCell:cell forStatsSection:statsSection andIndexPath:indexPath];
    }
}

- (void)configureSectionGraphCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    // Find the selected summary
    StatsVisits *visits = self.sectionData[@(StatsSectionGraph)];
    if (!visits) {
        return;
    }

    UILabel *iconLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:200];
    UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:300];

    StatsSummary *summary;
    for (StatsSummary *s in visits.statsData) {
        if ([s.date isEqualToDate:self.selectedDate]) {
            summary = s;
            break;
        }
    }
    
    switch (row) {
        case 0: // Graph Row
        {
            if (![[cell.contentView subviews] containsObject:self.graphViewController.view]) {
                UIView *graphView = self.graphViewController.view;
                graphView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(cell.contentView.bounds), StatsTableGraphHeight);
                graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [cell.contentView addSubview:graphView];
            }
            
            self.graphViewController.currentUnit = self.selectedPeriodUnit;
            self.graphViewController.currentSummaryType = self.selectedSummaryType;
            self.graphViewController.visits = visits;
            [self.graphViewController.collectionView reloadData];
            [self.graphViewController selectGraphBarWithDate:summary.date];
            
            break;
        }
            
        case 1: // Views
        {
            iconLabel.text = @"";
            textLabel.text = NSLocalizedString(@"Views", @"");
            valueLabel.text = summary.views;
            break;
        }
            
        case 2: // Visitors
        {
            iconLabel.text = @"";
            textLabel.text = NSLocalizedString(@"Visitors", @"");
            valueLabel.text = summary.visitors;
            break;
        }
            
        case 3: // Likes
        {
            iconLabel.text = @"";
            textLabel.text = NSLocalizedString(@"Likes", @"");
            valueLabel.text = summary.likes;
            break;
        }
            
        case 4: // Comments
        {
            iconLabel.text = @"";
            textLabel.text = NSLocalizedString(@"Comments", @"");
            valueLabel.text = summary.comments;
            break;
        }
            
        default:
            break;
    }
}

- (void)configureCell:(UITableViewCell *)cell forStatsSection:(StatsSection)statsSection andIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];

    if ([cellIdentifier isEqualToString:StatsTableGroupHeaderCellIdentifier]) {
        [self configureSectionGroupHeaderCell:cell
                             withStatsSection:statsSection];
    } else if ([cellIdentifier isEqualToString:StatsTableGroupSelectorCellIdentifier]) {
        [self configureSectionGroupSelectorCell:cell withStatsSection:statsSection];
    } else if ([cellIdentifier isEqualToString:StatsTableTwoColumnHeaderCellIdentifier]) {
        [self configureSectionTwoColumnHeaderCell:cell
                                 withStatsSection:statsSection];
    } else if ([cellIdentifier isEqualToString:StatsTableNoResultsCellIdentifier]) {
        // No data
    } else if ([cellIdentifier isEqualToString:StatsTableViewAllCellIdentifier]) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
        label.text = NSLocalizedString(@"View All", @"View All button in stats for larger list");
    } else if ([cellIdentifier isEqualToString:StatsTableTwoColumnCellIdentifier]) {
        StatsGroup *group = [self statsDataForStatsSection:statsSection];
        StatsItem *item = [group statsItemForTableViewRow:indexPath.row];
        
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL isNestedRow:item.depth > 1];
    }
}


- (void)configureSectionGroupHeaderCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    NSString *headerText;
    
    switch (statsSection) {
        case StatsSectionClicks:
            headerText = NSLocalizedString(@"Clicks", @"Title for stats section for Clicks");
            break;
        case StatsSectionComments:
            headerText = NSLocalizedString(@"Comments", @"Title for stats section for Comments");
            break;
        case StatsSectionCountry:
            headerText = NSLocalizedString(@"Countries", @"Title for stats section for Countries");
            break;
        case StatsSectionFollowers:
            headerText = NSLocalizedString(@"Followers", @"Title for stats section for Followers");
            break;
        case StatsSectionPosts:
            headerText = NSLocalizedString(@"Posts & Pages", @"Title for stats section for Posts & Pages");
            break;
        case StatsSectionPublicize:
            headerText = NSLocalizedString(@"Publicize", @"Title for stats section for Publicize");
            break;
        case StatsSectionReferrers:
            headerText = NSLocalizedString(@"Referrers", @"Title for stats section for Referrers");
            break;
        case StatsSectionTagsCategories:
            headerText = NSLocalizedString(@"Tags & Categories", @"Title for stats section for Tags & Categories");
            break;
        case StatsSectionVideos:
            headerText = NSLocalizedString(@"Videos", @"Title for stats section for Videos");
            break;
            
        default:
            break;
    }
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = headerText;
}


- (void)configureSectionTwoColumnHeaderCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    NSString *leftText;
    NSString *rightText;
    
    switch (statsSection) {
        case StatsSectionClicks:
            leftText = NSLocalizedString(@"Link", @"");
            rightText = NSLocalizedString(@"Clicks", @"");
            break;
        case StatsSectionComments:
        {
            StatsSubSection selectedSubsection = [self statsSubSectionForStatsSection:statsSection];

            leftText = selectedSubsection == StatsSubSectionCommentsByAuthor ? NSLocalizedString(@"Author", @"") : NSLocalizedString(@"Title", @"");
            rightText = NSLocalizedString(@"Comments", @"");
            break;
        }
        case StatsSectionCountry:
            leftText = NSLocalizedString(@"Country", @"");
            rightText = NSLocalizedString(@"Views", @"");
            break;
        case StatsSectionFollowers:
            leftText = NSLocalizedString(@"Follower", @"");
            rightText = NSLocalizedString(@"Since", @"");
            break;
        case StatsSectionPosts:
            leftText = NSLocalizedString(@"Title", @"");
            rightText = NSLocalizedString(@"Views", @"");
            break;
        case StatsSectionPublicize:
            leftText = NSLocalizedString(@"Service", @"");
            rightText = NSLocalizedString(@"Followers", @"");
            break;
        case StatsSectionReferrers:
            leftText = NSLocalizedString(@"Referrer", @"");
            rightText = NSLocalizedString(@"Views", @"");
            break;
        case StatsSectionTagsCategories:
            leftText = NSLocalizedString(@"Topic", @"");
            rightText = NSLocalizedString(@"Views", @"");
            break;
        case StatsSectionVideos:
            leftText = NSLocalizedString(@"Video", @"");
            rightText = NSLocalizedString(@"Views", @"");
            break;
            
        default:
            break;
    }
    
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
}


- (void)configureSectionGroupSelectorCell:(UITableViewCell *)cell withStatsSection:(StatsSection)statsSection
{
    NSArray *titles;
    NSInteger selectedIndex;
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


- (void)configureTwoColumnRowCell:(UITableViewCell *)cell withLeftText:(NSString *)leftText rightText:(NSString *)rightText andImageURL:(NSURL *)imageURL  isNestedRow:(BOOL)isNestedRow
{
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
    
    if (isNestedRow) {
        cell.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:300];
    imageView.image = nil;
    NSLayoutConstraint *widthConstraint;
    NSLayoutConstraint *spaceConstraint;
    
    for (NSLayoutConstraint *constraint in imageView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            widthConstraint = constraint;
            break;
        }
    }
    
    for (NSLayoutConstraint *constraint in cell.contentView.constraints) {
        if (constraint.firstItem == label1 && constraint.secondItem == imageView && constraint.firstAttribute == NSLayoutAttributeLeading) {
            spaceConstraint = constraint;
            break;
        }
    }

    // Hide the image if one isn't set
    if (imageURL) {
        widthConstraint.constant = 20.0f;
        spaceConstraint.constant = 8.0f;
        
        [[WPImageSource sharedSource] downloadImageForURL:imageURL withSuccess:^(UIImage *image) {
            imageView.image = image;
            imageView.backgroundColor = [UIColor clearColor];
        } failure:^(NSError *error) {
            DDLogWarn(@"Unable to download icon %@", error);
        }];
    } else {
        widthConstraint.constant = 0.0f;
        spaceConstraint.constant = 0.0f;
    }

    [cell setNeedsLayout];
}

#pragma mark - Row and section calculation methods

- (StatsSection)statsSectionForTableViewSection:(NSInteger)section
{
    return (StatsSection)[self.sections[section] integerValue];
}


- (StatsSubSection)statsSubSectionForStatsSection:(StatsSection)statsSection
{
    return (StatsSubSection)[self.selectedSubsections[@(statsSection)] integerValue];
}

- (id)statsDataForStatsSection:(StatsSection)statsSection
{
    id data;
    
    if ( statsSection == StatsSectionComments || statsSection == StatsSectionFollowers) {
        StatsSubSection selectedSubsection = [self statsSubSectionForStatsSection:statsSection];
        data = self.sectionData[@(statsSection)][@(selectedSubsection)];
    } else if (statsSection != StatsSectionPeriodSelector) {
        data = self.sectionData[@(statsSection)];
    }
    
    return data;
}

@end

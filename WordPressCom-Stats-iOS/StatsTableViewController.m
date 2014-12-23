#import "StatsTableViewController.h"
#import "WPStatsGraphViewController.h"
#import "WPStatsService.h"
#import "StatsGroup.h"
#import "StatsItem.h"
#import "StatsGroup+View.h"
#import "StatsItem+View.h"
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

static CGFloat const kGraphHeight = 175.0f;
static CGFloat const kNoResultsHeight = 100.0f;

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
    id data = self.sectionData[@(statsSection)];
    
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
        {
            StatsGroup *statsGroup = (StatsGroup *)data;
            NSUInteger count = statsGroup.items.count + 2;
            
            if (statsGroup.moreItemsExist) {
                count++;
            }
            
            return count;
        }
        case StatsSectionComments:
        case StatsSectionFollowers:
        {
            StatsSubSection selectedSubsection = (StatsSubSection)[self.selectedSubsections[@(statsSection)] integerValue];
            StatsGroup *group = self.sectionData[@(statsSection)][@(selectedSubsection)];
            
            NSUInteger count = group.items.count;
            count = count + 3;
            
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

    if ([cellIdentifier isEqualToString:@"GraphRow"]) {
        return kGraphHeight;
    } else if ([cellIdentifier isEqualToString:@"NoResultsRow"]) {
        return kNoResultsHeight;
    } else if ([cellIdentifier isEqualToString:@"SelectableRow"]) {
        return 35.0f;
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
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:@"MoreRow"]) {
        return indexPath;
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
    } else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:@"MoreRow"]) {
        // Placeholder for full screen details
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    for (int x = 3; x < oldSectionCount; ++x) {
        [oldIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:sectionNumber]];
    }
    for (int x = 3; x < newSectionCount; ++x) {
        [newIndexPaths addObject:[NSIndexPath indexPathForRow:x inSection:sectionNumber]];
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
         self.sectionData[@(StatsSectionPosts)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionPosts)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                     referrersCompletionHandler:^(StatsGroup *group)
     {
         self.sectionData[@(StatsSectionReferrers)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionReferrers)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                        clicksCompletionHandler:^(StatsGroup *group)
     {
         self.sectionData[@(StatsSectionClicks)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionClicks)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                       countryCompletionHandler:^(StatsGroup *group)
     {
         self.sectionData[@(StatsSectionCountry)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionCountry)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                        videosCompletionHandler:^(StatsGroup *group)
     {
         self.sectionData[@(StatsSectionVideos)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionVideos)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
                commentsAuthorCompletionHandler:^(StatsGroup *group)
     {
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
         self.sectionData[@(StatsSectionTagsCategories)] = group;
         
         [self.tableView beginUpdates];
         
         NSUInteger sectionNumber = [self.sections indexOfObject:@(StatsSectionTagsCategories)];
         NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionNumber];
         [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
         [self.tableView endUpdates];
     }
               followersDotComCompletionHandler:^(StatsGroup *group)
     {
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
            identifier = @"PeriodSelector";
            break;
        case StatsSectionGraph: {
            switch (indexPath.row) {
                case 0:
                    if (self.sectionData[@(statsSection)] != nil) {
                        identifier = @"GraphRow";
                    } else {
                        identifier = @"NoResultsRow";
                    }
                    break;
                    
                default:
                    identifier = @"SelectableRow";
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
            StatsGroup *group = (StatsGroup *)self.sectionData[@(statsSection)];
            if (indexPath.row == 0) {
                identifier = @"GroupHeader";
            } else if (indexPath.row == 1 && group.items.count > 0) {
                identifier = @"TwoColumnHeader";
            } else if (indexPath.row == 1) {
                identifier = @"NoResultsRow";
            } else if (group.moreItemsExist && indexPath.row == (group.items.count + 2)) {
                identifier = @"MoreRow";
            } else {
                identifier = @"TwoColumnRow";
            }
            break;
        }
            
        case StatsSectionComments:
        case StatsSectionFollowers:
        {
            StatsSubSection selectedSubsection = (StatsSubSection)[self.selectedSubsections[@(statsSection)] integerValue];
            StatsGroup *group = self.sectionData[@(statsSection)][@(selectedSubsection)];

            switch (indexPath.row) {
                case 0:
                    identifier = @"GroupHeader";
                    break;
                case 1:
                    identifier = @"GroupSelector";
                    break;
                case 2:
                {
                    if (group.items.count > 0) {
                        identifier = @"TwoColumnHeader";
                    } else {
                        identifier = @"NoResultsRow";
                    }
                    break;
                }
                default:
                    if (group.moreItemsExist && indexPath.row == (group.items.count + 3)) {
                        identifier = @"MoreRow";
                    } else {
                        identifier = @"TwoColumnRow";
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
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    
    if ([cellIdentifier isEqualToString:@"MoreRow"]) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
        label.text = NSLocalizedString(@"View All", @"View All button in stats for larger list");
        return;
    }
    
    switch (statsSection) {
        case StatsSectionPeriodSelector:
            break;
        case StatsSectionGraph:
            [self configureSectionGraphCell:cell forRow:indexPath.row];
            break;
        case StatsSectionPosts:
            [self configureSectionPostsCell:cell forRow:indexPath.row];
            break;
        case StatsSectionReferrers:
            [self configureSectionReferrersCell:cell forRow:indexPath.row];
            break;
        case StatsSectionClicks:
            [self configureSectionClicksCell:cell forRow:indexPath.row];
            break;
        case StatsSectionCountry:
            [self configureSectionCountryCell:cell forRow:indexPath.row];
            break;
        case StatsSectionVideos:
            [self configureSectionVideosCell:cell forRow:indexPath.row];
            break;
        case StatsSectionComments:
            [self configureSectionCommentsCell:cell forRow:indexPath.row];
            break;
        case StatsSectionTagsCategories:
            [self configureSectionTagsCategoriesCell:cell forRow:indexPath.row];
            break;
        case StatsSectionFollowers:
            [self configureSectionFollowersCell:cell forRow:indexPath.row];
            break;
        case StatsSectionPublicize:
            [self configureSectionPublicizeCell:cell forRow:indexPath.row];
            break;
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
                graphView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(cell.contentView.bounds), kGraphHeight);
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

- (void)configureSectionPostsCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionPosts)];
    BOOL dataExists = group.items.count > 0;

    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Posts & Pages", @"Title for stats section for Posts & Pages")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Title", @"")
                                     andRightText:NSLocalizedString(@"Views", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionReferrersCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionReferrers)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Referrers", @"Title for stats section for Referrers")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Referrer", @"")
                                     andRightText:NSLocalizedString(@"Views", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionClicksCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionClicks)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Clicks", @"Title for stats section for Clicks")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Link", @"")
                                     andRightText:NSLocalizedString(@"Clicks", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionCountryCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionCountry)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Countries", @"Title for stats section for Countries")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Country", @"")
                                     andRightText:NSLocalizedString(@"Views", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionVideosCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionVideos)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Videos", @"Title for stats section for Videos")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Video", @"")
                                     andRightText:NSLocalizedString(@"Views", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
}

- (void)configureSectionCommentsCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsSubSection selectedSubsection = (StatsSubSection)[self.selectedSubsections[@(StatsSectionComments)] integerValue];
    StatsGroup *group = self.sectionData[@(StatsSectionComments)][@(selectedSubsection)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Comments", @"Title for stats section for Comments")];
    } else if (row == 1) {
        NSInteger selectedIndex = selectedSubsection == StatsSubSectionCommentsByAuthor ? 0 : 1;

        [self configureSectionGroupSelectorCell:cell
                                     withTitles:@[NSLocalizedString(@"By Authors", @"Authors segmented control for stats"),
                                                  NSLocalizedString(@"By Posts & Pages", @"Posts & Pages segmented control for stats")]
                        andSelectedSegmentIndex:selectedIndex
                                     forSection:StatsSectionComments];
    } else if (row == 2 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:selectedSubsection == StatsSubSectionCommentsByAuthor ? NSLocalizedString(@"Author", @"") : NSLocalizedString(@"Title", @"")
                                     andRightText:NSLocalizedString(@"Comments", @"")];
    } else if (row == 2 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 3) {
        // More
    } else if (row > 2) {
        StatsItem *item = group.items[row - 3];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionTagsCategoriesCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionTagsCategories)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Tags & Categories", @"Title for stats section for Tags & Categories")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Topic", @"")
                                     andRightText:NSLocalizedString(@"Views", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionFollowersCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsSubSection selectedSubsection = (StatsSubSection)[self.selectedSubsections[@(StatsSectionFollowers)] integerValue];
    StatsGroup *group = self.sectionData[@(StatsSectionFollowers)][@(selectedSubsection)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Followers", @"Title for stats section for Followers")];
    } else if (row == 1) {
        NSInteger selectedIndex = selectedSubsection == StatsSubSectionFollowersDotCom ? 0 : 1;
        
        [self configureSectionGroupSelectorCell:cell
                                     withTitles:@[NSLocalizedString(@"WordPress.com", @"WordPress.com segmented control for stats"),
                                                  NSLocalizedString(@"Email", @"Email segmented control for stats")]
                        andSelectedSegmentIndex:selectedIndex
                                     forSection:StatsSectionFollowers];
    } else if (row == 2 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Follower", @"")
                                     andRightText:NSLocalizedString(@"Since", @"")];
    } else if (row == 2 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 3) {
        // More
    } else if (row > 2) {
        StatsItem *item = group.items[row - 3];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionPublicizeCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    StatsGroup *group = (StatsGroup *)self.sectionData[@(StatsSectionPublicize)];
    BOOL dataExists = group.items.count > 0;
    
    if (row == 0) {
        [self configureSectionGroupHeaderCell:cell withText:NSLocalizedString(@"Publicize", @"Title for stats section for Publicize")];
    } else if (row == 1 && dataExists) {
        [self configureSectionTwoColumnHeaderCell:cell
                                     withLeftText:NSLocalizedString(@"Service", @"")
                                     andRightText:NSLocalizedString(@"Followers", @"")];
    } else if (row == 1 && !dataExists) {
        // No data
    } else if (group.moreItemsExist && row == group.items.count + 2) {
        // More
    } else if (row > 1) {
        StatsItem *item = group.items[row - 2];
        [self configureTwoColumnRowCell:cell withLeftText:item.label rightText:item.value andImageURL:item.iconURL];
    }
    
}

- (void)configureSectionGroupHeaderCell:(UITableViewCell *)cell withText:(NSString *)headerText
{
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    label.text = headerText;
}

- (void)configureSectionTwoColumnHeaderCell:(UITableViewCell *)cell withLeftText:(NSString *)leftText andRightText:(NSString *)rightText
{
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
}

- (void)configureSectionGroupSelectorCell:(UITableViewCell *)cell withTitles:(NSArray *)titles andSelectedSegmentIndex:(NSInteger)index forSection:(StatsSection)statsSection
{
    UISegmentedControl *control = (UISegmentedControl *)[cell.contentView viewWithTag:100];
    cell.contentView.tag = statsSection;
    
    [control removeAllSegments];
    
    for (NSString *title in [titles reverseObjectEnumerator]) {
        [control insertSegmentWithTitle:title atIndex:0 animated:NO];
    }
    
    control.selectedSegmentIndex = index;
}

- (void)configureTwoColumnRowCell:(UITableViewCell *)cell withLeftText:(NSString *)leftText rightText:(NSString *)rightText andImageURL:(NSURL *)imageURL
{
    UILabel *label1 = (UILabel *)[cell.contentView viewWithTag:100];
    label1.text = leftText;
    
    UILabel *label2 = (UILabel *)[cell.contentView viewWithTag:200];
    label2.text = rightText;
    
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

- (NSUInteger)numberOfRowsForStatsGroup:(StatsGroup *)group
{
    return group.expanded == NO ? 0 : [self numberOfRowsForStatsItems:group.items];
}

- (NSUInteger)numberOfRowsForStatsItems:(NSArray *)items
{
    if (items.count == 0) {
        return 0;
    }
    
    NSUInteger itemCount = items.count;
    
    for (StatsItem *item in items) {
        itemCount += [self numberOfRowsForStatsItems:item.children];
    }
    
    return itemCount;
}

- (StatsSection)statsSectionForTableViewSection:(NSInteger)section
{
    return (StatsSection)[self.sections[section] integerValue];
}


@end

#import "InsightsTableViewController.h"
#import "WPFontManager+Stats.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"
#import "StatsGaugeView.h"
#import "InsightsSectionHeaderTableViewCell.h"
#import "InsightsAllTimeTableViewCell.h"
#import "InsightsMostPopularTableViewCell.h"
#import "InsightsTodaysStatsTableViewCell.h"
#import "StatsTableSectionHeaderView.h"
#import "StatsSection.h"
#import <WordPressCom-Analytics-iOS/WPAnalytics.h>

@interface InlineTextAttachment : NSTextAttachment

@property (nonatomic, assign) CGFloat fontDescender;

@end

@implementation InlineTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect superRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    superRect.origin.y = self.fontDescender;
    return superRect;
}

@end

static NSString *const StatsTableSectionHeaderSimpleBorder = @"StatsTableSectionHeaderSimpleBorder";
static NSString *const InsightsTableSectionHeaderCellIdentifier = @"HeaderRow";
static NSString *const InsightsTableMostPopularDetailsCellIdentifier = @"MostPopularDetails";
static NSString *const InsightsTableAllTimeDetailsCellIdentifier = @"AllTimeDetails";
static NSString *const InsightsTableTodaysStatsDetailsCellIdentifier = @"TodaysStatsDetails";
static NSString *const InsightsTableAllTimeDetailsiPadCellIdentifier = @"AllTimeDetailsPad";
static NSString *const InsightsTableTodaysStatsDetailsiPadCellIdentifier = @"TodaysStatsDetailsPad";

@interface InsightsTableViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableDictionary *sectionData;

@end

@implementation InsightsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass:[StatsTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:StatsTableSectionHeaderSimpleBorder];
    
    self.sections = @[@(StatsSectionInsightsMostPopular),
                      @(StatsSectionInsightsAllTime),
                      @(StatsSectionInsightsTodaysStats)];
    
    [self wipeDataAndSeedGroups];

    [self setupRefreshControl];

    [self retrieveStats];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [WPAnalytics track:WPAnalyticsStatStatsInsightsAccessed];
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (NSInteger)self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
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
    NSString *identifier = [self cellIdentifierForIndexPath:indexPath];
    
    if ([identifier isEqualToString:InsightsTableSectionHeaderCellIdentifier]) {
        return 44.0f;
    } else if ([identifier isEqualToString:InsightsTableMostPopularDetailsCellIdentifier]) {
        return 150.0f;
    } else if ([identifier isEqualToString:InsightsTableAllTimeDetailsCellIdentifier]) {
        return 185.0f;
    } else if ([identifier isEqualToString:InsightsTableAllTimeDetailsiPadCellIdentifier]) {
        return 100.0f;
    } else if ([identifier isEqualToString:InsightsTableTodaysStatsDetailsiPadCellIdentifier]) {
        return 66.0f;
    } else if ([identifier isEqualToString:InsightsTableTodaysStatsDetailsCellIdentifier]) {
        return 132.0f;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        if ([self.statsTypeSelectionDelegate conformsToProtocol:@protocol(WPStatsSummaryTypeSelectionDelegate)]) {
            [self.statsTypeSelectionDelegate viewController:self changeStatsSummaryTypeSelection:StatsSummaryTypeViews];
        }
    }
}


#pragma mark - Private cell configuration methods

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    
    StatsSection statsSection = [self statsSectionForTableViewSection:indexPath.section];
    
    switch (statsSection) {
        case StatsSectionInsightsAllTime:
            if (indexPath.row == 0) {
                identifier = InsightsTableSectionHeaderCellIdentifier;
            } else {
                identifier = IS_IPAD ? InsightsTableAllTimeDetailsiPadCellIdentifier : InsightsTableAllTimeDetailsCellIdentifier;
            }
            break;
    
        case StatsSectionInsightsMostPopular:
            if (indexPath.row == 0) {
                identifier = InsightsTableSectionHeaderCellIdentifier;
            } else {
                identifier = InsightsTableMostPopularDetailsCellIdentifier;
            }
            break;

        case StatsSectionInsightsTodaysStats:
            if (indexPath.row == 0) {
                identifier = InsightsTableSectionHeaderCellIdentifier;
            } else {
                identifier = IS_IPAD ? InsightsTableTodaysStatsDetailsiPadCellIdentifier : InsightsTableTodaysStatsDetailsCellIdentifier;
            }
            break;

        case StatsSectionGraph:
        case StatsSectionPeriodHeader:
        case StatsSectionEvents:
        case StatsSectionPosts:
        case StatsSectionReferrers:
        case StatsSectionClicks:
        case StatsSectionCountry:
        case StatsSectionVideos:
        case StatsSectionAuthors:
        case StatsSectionSearchTerms:
        case StatsSectionTagsCategories:
        case StatsSectionPublicize:
        case StatsSectionFollowers:
        case StatsSectionComments:
        case StatsSectionWebVersion:
        case StatsSectionPostDetailsAveragePerDay:
        case StatsSectionPostDetailsGraph:
        case StatsSectionPostDetailsLoadingIndicator:
        case StatsSectionPostDetailsMonthsYears:
        case StatsSectionPostDetailsRecentWeeks:
            break;
    }
    
    return identifier;
}


- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = cell.reuseIdentifier;
    
    if ([identifier isEqualToString:InsightsTableSectionHeaderCellIdentifier]) {
        [self configureSectionHeaderCell:(InsightsSectionHeaderTableViewCell *)cell forSection:indexPath.section];
    } else if ([identifier isEqualToString:InsightsTableAllTimeDetailsCellIdentifier] || [identifier isEqualToString:InsightsTableAllTimeDetailsiPadCellIdentifier]) {
        [self configureAllTimeCell:(InsightsAllTimeTableViewCell *)cell];
    } else if ([identifier isEqualToString:InsightsTableMostPopularDetailsCellIdentifier]) {
        [self configureMostPopularCell:(InsightsMostPopularTableViewCell *)cell];
    } else if ([identifier isEqualToString:InsightsTableTodaysStatsDetailsCellIdentifier] || [identifier isEqualToString:InsightsTableTodaysStatsDetailsiPadCellIdentifier]) {
        [self configureTodaysStatsCell:(InsightsTodaysStatsTableViewCell *)cell];
    } else {
        DDLogWarn(@"ConfigureCell called with unknown cell identifier: %@", identifier);
    }
}


- (void)configureSectionHeaderCell:(InsightsSectionHeaderTableViewCell *)cell forSection:(NSInteger)section
{
    StatsSection statsSection = [self statsSectionForTableViewSection:section];

    cell.sectionHeaderLabel.textColor = [WPStyleGuide greyDarken10];
    
    switch (statsSection) {
        case StatsSectionInsightsAllTime:
            cell.sectionHeaderLabel.text = NSLocalizedString(@"All-time posts, views, and visitors", @"Insights all time section header");
            break;
        case StatsSectionInsightsMostPopular:
            cell.sectionHeaderLabel.text = NSLocalizedString(@"Most popular day and hour", @"Insights popular section header");
            break;
        case StatsSectionInsightsTodaysStats:
            cell.sectionHeaderLabel.text = NSLocalizedString(@"Today's Stats", @"Insights today section header");
            break;
        default:
            break;
    }
}


- (void)configureAllTimeCell:(InsightsAllTimeTableViewCell *)cell
{
    cell.allTimePostsLabel.attributedText = [self postsAttributedStringWithFont:cell.allTimePostsLabel.font];
    cell.allTimeViewsLabel.attributedText = [self viewsAttributedStringWithFont:cell.allTimeViewsLabel.font];
    cell.allTimeVisitorsLabel.attributedText = [self visitorsAttributedStringWithFont:cell.allTimeVisitorsLabel.font];
    cell.allTimeBestViewsLabel.attributedText = [self bestViewsAttributedStringWithFont:cell.allTimeBestViewsLabel.font];

    StatsAllTime *statsAllTime = self.sectionData[@(StatsSectionInsightsAllTime)];
    
    if (!statsAllTime) {
        cell.allTimePostsValueLabel.text = @"-";
        cell.allTimePostsValueLabel.textColor = [WPStyleGuide greyLighten20];
        cell.allTimeViewsValueLabel.text = @"-";
        cell.allTimeViewsValueLabel.textColor = [WPStyleGuide greyLighten20];
        cell.allTimeVisitorsValueLabel.text = @"-";
        cell.allTimeVisitorsValueLabel.textColor = [WPStyleGuide greyLighten20];
        cell.allTimeBestViewsValueLabel.text = @"-";
        cell.allTimeBestViewsValueLabel.textColor = [WPStyleGuide greyLighten20];
        cell.allTimeBestViewsOnValueLabel.text = NSLocalizedString(@"Unknown", @"Unknown data in value label");
        cell.allTimeBestViewsOnValueLabel.textColor = [WPStyleGuide greyLighten20];
    } else {
        cell.allTimePostsValueLabel.textColor = [WPStyleGuide greyDarken30];
        cell.allTimePostsValueLabel.text = statsAllTime.numberOfPosts;
        cell.allTimeViewsValueLabel.textColor = [WPStyleGuide greyDarken30];
        cell.allTimeViewsValueLabel.text = statsAllTime.numberOfViews;
        cell.allTimeVisitorsValueLabel.textColor = [WPStyleGuide greyDarken30];
        cell.allTimeVisitorsValueLabel.text = statsAllTime.numberOfVisitors;
        cell.allTimeBestViewsValueLabel.textColor = [WPStyleGuide greyDarken30];
        cell.allTimeBestViewsValueLabel.text = statsAllTime.bestNumberOfViews;
        cell.allTimeBestViewsOnValueLabel.textColor = [WPStyleGuide greyDarken10];
        cell.allTimeBestViewsOnValueLabel.text = statsAllTime.bestViewsOn;
    }
}


- (void)configureMostPopularCell:(InsightsMostPopularTableViewCell *)cell
{
    cell.mostPopularDayLabel.text = [NSLocalizedString(@"Most popular day", @"Insights most popular day section label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    cell.mostPopularDayLabel.textColor = [WPStyleGuide greyDarken10];
    cell.mostPopularHourLabel.text = [NSLocalizedString(@"Most popular hour", @"Insights most popular hour section label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    cell.mostPopularHourLabel.textColor = [WPStyleGuide greyDarken10];

    StatsInsights *statsInsights = self.sectionData[@(StatsSectionInsightsMostPopular)];
    
    cell.mostPopularDayPercentWeeklyViews.textColor = [WPStyleGuide greyDarken10];
    cell.mostPopularHourPercentDailyViews.textColor = [WPStyleGuide greyDarken10];

    if (!statsInsights) {
        cell.mostPopularDay.text = @"-";
        cell.mostPopularDay.textColor = [WPStyleGuide greyLighten20];
        cell.mostPopularDayPercentWeeklyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), @"-"];
        cell.mostPopularHour.text = @"-";
        cell.mostPopularHour.textColor = [WPStyleGuide greyLighten20];
        cell.mostPopularHourPercentDailyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), @"-"];
    } else {
        cell.mostPopularDay.text = statsInsights.highestDayOfWeek;
        cell.mostPopularDay.textColor = [WPStyleGuide greyDarken30];
        cell.mostPopularHour.text = statsInsights.highestHour;
        cell.mostPopularHour.textColor = [WPStyleGuide greyDarken30];
        cell.mostPopularDayPercentWeeklyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), statsInsights.highestDayPercent];
        cell.mostPopularHourPercentDailyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), statsInsights.highestHourPercent];
    }
    
}


- (void)configureTodaysStatsCell:(InsightsTodaysStatsTableViewCell *)cell
{
    [cell.todayViewsButton setAttributedTitle:[self viewsAttributedStringWithFont:cell.todayViewsButton.titleLabel.font] forState:UIControlStateNormal];
    [cell.todayVisitorsButton setAttributedTitle:[self visitorsAttributedStringWithFont:cell.todayVisitorsButton.titleLabel.font] forState:UIControlStateNormal];
    [cell.todayLikesButton setAttributedTitle:[self likesAttributedStringWithFont:cell.todayLikesButton.titleLabel.font] forState:UIControlStateNormal];
    [cell.todayCommentsButton setAttributedTitle:[self commentsAttributedStringWithFont:cell.todayCommentsButton.titleLabel.font] forState:UIControlStateNormal];
    
    StatsSummary *todaySummary = self.sectionData[@(StatsSectionInsightsTodaysStats)];
    
    if (!todaySummary) {
        // Default values for no data
        [cell.todayViewsValueButton setTitle:@"-" forState:UIControlStateNormal];
        [cell.todayViewsValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
        [cell.todayVisitorsValueButton setTitle:@"-" forState:UIControlStateNormal];
        [cell.todayVisitorsValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
        [cell.todayLikesValueButton setTitle:@"-" forState:UIControlStateNormal];
        [cell.todayLikesValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
        [cell.todayCommentsValueButton setTitle:@"-" forState:UIControlStateNormal];
        [cell.todayCommentsValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
    } else {
        [cell.todayViewsValueButton setTitle:todaySummary.views forState:UIControlStateNormal];
        [cell.todayViewsValueButton setTitleColor:todaySummary.viewsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
        [cell.todayVisitorsValueButton setTitle:todaySummary.visitors forState:UIControlStateNormal];
        [cell.todayVisitorsValueButton setTitleColor:todaySummary.visitorsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
        [cell.todayLikesValueButton setTitle:todaySummary.likes forState:UIControlStateNormal];
        [cell.todayLikesValueButton setTitleColor:todaySummary.likesValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
        [cell.todayCommentsValueButton setTitle:todaySummary.comments forState:UIControlStateNormal];
        [cell.todayCommentsValueButton setTitleColor:todaySummary.commentsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
    }

}


#pragma mark - Private methods


- (IBAction)refreshCurrentStats:(UIRefreshControl *)sender
{
    [self.statsService expireAllItemsInCacheForInsights];
    [self retrieveStats];
}


- (void)retrieveStats
{
    if ([self.statsProgressViewDelegate respondsToSelector:@selector(statsViewControllerDidBeginLoadingStats:)]
        && self.refreshControl.isRefreshing == NO) {
        self.refreshControl = nil;
    }
    
    [self.statsService retrieveInsightsStatsWithAllTimeStatsCompletionHandler:^(StatsAllTime *allTime, NSError *error)
     {
         if (allTime) {
             self.sectionData[@(StatsSectionInsightsAllTime)] = allTime;
         }
     }
                                                    insightsCompletionHandler:^(StatsInsights *insights, NSError *error)
     {
         if (insights) {
             self.sectionData[@(StatsSectionInsightsMostPopular)] = insights;
         }
     }
                                                todaySummaryCompletionHandler:^(StatsSummary *summary, NSError *error)
     {
         if (summary) {
             self.sectionData[@(StatsSectionInsightsTodaysStats)] = summary;
         }
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
         // Set the colors to what they should be (previous color for unknown data)
         
         [self setupRefreshControl];
         [self.refreshControl endRefreshing];
         
         
         // FIXME - Do something elegant possibly
         [self.tableView reloadData];
         
         if ([self.statsProgressViewDelegate respondsToSelector:@selector(statsViewControllerDidEndLoadingStats:)]) {
             [self.statsProgressViewDelegate statsViewControllerDidEndLoadingStats:self];
         }
     }];
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


#pragma mark - Actions for today stats


- (IBAction)switchToTodayViews:(UIButton *)button
{
    if ([self.statsTypeSelectionDelegate conformsToProtocol:@protocol(WPStatsSummaryTypeSelectionDelegate)]) {
        [self.statsTypeSelectionDelegate viewController:self changeStatsSummaryTypeSelection:StatsSummaryTypeViews];
    }
}

- (IBAction)switchToTodayVisitors:(UIButton *)button
{
    if ([self.statsTypeSelectionDelegate conformsToProtocol:@protocol(WPStatsSummaryTypeSelectionDelegate)]) {
        [self.statsTypeSelectionDelegate viewController:self changeStatsSummaryTypeSelection:StatsSummaryTypeVisitors];
    }
}

- (IBAction)switchToTodayLikes:(UIButton *)button
{
    if ([self.statsTypeSelectionDelegate conformsToProtocol:@protocol(WPStatsSummaryTypeSelectionDelegate)]) {
        [self.statsTypeSelectionDelegate viewController:self changeStatsSummaryTypeSelection:StatsSummaryTypeLikes];
    }
}

- (IBAction)switchToTodayComments:(UIButton *)button
{
    if ([self.statsTypeSelectionDelegate conformsToProtocol:@protocol(WPStatsSummaryTypeSelectionDelegate)]) {
        [self.statsTypeSelectionDelegate viewController:self changeStatsSummaryTypeSelection:StatsSummaryTypeComments];
    }
}


#pragma mark - Attributed String generation methods

- (NSMutableAttributedString *)postsAttributedStringWithFont:(UIFont *)font
{
    NSMutableAttributedString *postsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Posts", @"Stats Posts label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *postsTextAttachment = [InlineTextAttachment new];
    postsTextAttachment.fontDescender = font.descender;
    postsTextAttachment.image = [self postsImage];
    [postsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:postsTextAttachment] atIndex:0];
    [postsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [postsText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [postsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, postsText.length)];

    return postsText;
}

- (NSMutableAttributedString *)viewsAttributedStringWithFont:(UIFont *)font
{
    NSMutableAttributedString *viewsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Views", @"Stats Views label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *viewsTextAttachment = [InlineTextAttachment new];
    viewsTextAttachment.fontDescender = font.descender;
    viewsTextAttachment.image = [self viewsImage];
    [viewsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:viewsTextAttachment] atIndex:0];
    [viewsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [viewsText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [viewsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, viewsText.length)];

    return viewsText;
}

- (NSMutableAttributedString *)visitorsAttributedStringWithFont:(UIFont *)font
{
    NSMutableAttributedString *visitorsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Visitors", @"Stats Visitors label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *visitorsTextAttachment = [InlineTextAttachment new];
    visitorsTextAttachment.fontDescender = font.descender;
    visitorsTextAttachment.image = [self visitorsImage];
    [visitorsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:visitorsTextAttachment] atIndex:0];
    [visitorsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [visitorsText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [visitorsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, visitorsText.length)];

    return visitorsText;
}

- (NSMutableAttributedString *)bestViewsAttributedStringWithFont:(UIFont *)font
{
    NSMutableAttributedString *bestViewsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Best Views Ever", @"Stats Best Views label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *bestViewsTextAttachment = [InlineTextAttachment new];
    bestViewsTextAttachment.fontDescender = font.descender;
    bestViewsTextAttachment.image = [self bestViewsImage];
    [bestViewsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:bestViewsTextAttachment] atIndex:0];
    [bestViewsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [bestViewsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide warningYellow] range:NSMakeRange(0, bestViewsText.length)];

    return bestViewsText;
}

- (NSMutableAttributedString *)likesAttributedStringWithFont:(UIFont *)font
{
    NSMutableAttributedString *likesText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Likes", @"Stats Likes label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *likesTextAttachment = [InlineTextAttachment new];
    likesTextAttachment.fontDescender = font.descender;
    likesTextAttachment.image = [self likesImage];
    [likesText insertAttributedString:[NSAttributedString attributedStringWithAttachment:likesTextAttachment] atIndex:0];
    [likesText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [likesText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [likesText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, likesText.length)];

    return likesText;
}

- (NSMutableAttributedString *)commentsAttributedStringWithFont:(UIFont *)font
{
    NSMutableAttributedString *commentsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Comments", @"Stats Comments label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *commentsTextAttachment = [InlineTextAttachment new];
    commentsTextAttachment.fontDescender = font.descender;
    commentsTextAttachment.image = [self commentsImage];
    [commentsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:commentsTextAttachment] atIndex:0];
    [commentsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [commentsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, commentsText.length)];

    return commentsText;
}

#pragma mark - Image methods

- (NSBundle *)bundle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WordPressCom-Stats-iOS" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];

    return bundle;
}

- (UIImage *)postsImage
{
    NSBundle *bundle = [self bundle];
    UIImage *postsImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        postsImage = [UIImage imageNamed:@"icon-text_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        postsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-text_normal" ofType:@"png"]];
    }
    
    return postsImage;
}

- (UIImage *)viewsImage
{
    NSBundle *bundle = [self bundle];
    UIImage *viewsImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        viewsImage = [UIImage imageNamed:@"icon-eye_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        viewsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-eye_normal" ofType:@"png"]];
    }
    
    return viewsImage;
}

- (UIImage *)visitorsImage
{
    NSBundle *bundle = [self bundle];
    UIImage *visitorsImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        visitorsImage = [UIImage imageNamed:@"icon-user_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        visitorsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-user_normal" ofType:@"png"]];
    }
    
    return visitorsImage;
}

- (UIImage *)bestViewsImage
{
    NSBundle *bundle = [self bundle];
    UIImage *bestViewsImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        bestViewsImage = [UIImage imageNamed:@"icon-trophy_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        bestViewsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-trophy_normal" ofType:@"png"]];
    }
    
    return bestViewsImage;
}

- (UIImage *)likesImage
{
    NSBundle *bundle = [self bundle];
    UIImage *likesImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        likesImage = [UIImage imageNamed:@"icon-star_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        likesImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-star_normal" ofType:@"png"]];
    }
    
    return likesImage;
}

- (UIImage *)commentsImage
{
    NSBundle *bundle = [self bundle];
    UIImage *commentsImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        commentsImage = [UIImage imageNamed:@"icon-comment_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        commentsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-comment_normal" ofType:@"png"]];
    }
    
    return commentsImage;
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
}


@end

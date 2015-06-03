#import "InsightsTableViewController.h"
#import "WPFontManager+Stats.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"
#import "StatsGaugeView.h"

@interface InlineTextAttachment : NSTextAttachment

@property CGFloat fontDescender;

@end

@implementation InlineTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect superRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    superRect.origin.y = self.fontDescender;
    return superRect;
}

@end


@interface InsightsTableViewController ()

// Most popular section
@property (nonatomic, weak) IBOutlet UILabel *popularSectionHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDayLabel;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDayPercentWeeklyViews;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHourLabel;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHourPercentDailyViews;
// All time section
@property (nonatomic, weak) IBOutlet UILabel *allTimeSectionHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimePostsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsLabel;
// Today section
@property (nonatomic, weak) IBOutlet UILabel *todaySectionHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayViewsLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayVisitorsLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayLikesLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayCommentsLabel;

// Values
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDay;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHour;
@property (nonatomic, weak) IBOutlet UILabel *allTimePostsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsOnValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayVisitorsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayLikesValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *todayCommentsValueLabel;

@end

@implementation InsightsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupRefreshControl];

    self.popularSectionHeaderLabel.text = NSLocalizedString(@"Most popular day and hour", @"Insights popular section header");
    self.popularSectionHeaderLabel.textColor = [WPStyleGuide greyDarken10];
    self.mostPopularDayLabel.text = [NSLocalizedString(@"Most popular day", @"Insights most popular day section label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.mostPopularDayLabel.textColor = [WPStyleGuide greyDarken10];
    self.mostPopularHourLabel.text = [NSLocalizedString(@"Most popular hour", @"Insights most popular hour section label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.mostPopularHourLabel.textColor = [WPStyleGuide greyDarken10];
    self.allTimeSectionHeaderLabel.text = NSLocalizedString(@"All-time posts, views, and visitors", @"Insights all time section header");
    self.allTimeSectionHeaderLabel.textColor = [WPStyleGuide greyDarken10];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WordPressCom-Stats-iOS" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    UIImage *postsImage;
    UIImage *viewsImage;
    UIImage *visitorsImage;
    UIImage *bestViewsImage;
    UIImage *likesImage;
    UIImage *commentsImage;
    
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        postsImage = [UIImage imageNamed:@"icon-eye_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
        viewsImage = [UIImage imageNamed:@"icon-text_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
        visitorsImage = [UIImage imageNamed:@"icon-user_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
        bestViewsImage = [UIImage imageNamed:@"icon-trophy_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
        likesImage = [UIImage imageNamed:@"icon-star_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
        commentsImage = [UIImage imageNamed:@"icon-comment_normal.png" inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        postsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-eye_normal" ofType:@"png"]];
        viewsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-text_normal" ofType:@"png"]];
        visitorsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-user_normal" ofType:@"png"]];
        bestViewsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-trophy_normal" ofType:@"png"]];
        likesImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-star_normal" ofType:@"png"]];
        commentsImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon-comment_normal" ofType:@"png"]];
    }

    NSMutableAttributedString *allTimesPostsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Posts", @"Stats Posts label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *allTimesPostsTextAttachment = [InlineTextAttachment new];
    allTimesPostsTextAttachment.fontDescender = self.allTimeViewsLabel.font.descender;
    allTimesPostsTextAttachment.image = postsImage;
    [allTimesPostsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:allTimesPostsTextAttachment] atIndex:0];
    [allTimesPostsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    self.allTimePostsLabel.attributedText = allTimesPostsText;
    self.allTimePostsLabel.textColor = [WPStyleGuide greyDarken20];

    NSMutableAttributedString *allTimesViewsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Views", @"Stats Views label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *allTimesViewsTextAttachment = [InlineTextAttachment new];
    allTimesViewsTextAttachment.fontDescender = self.allTimeViewsLabel.font.descender;
    allTimesViewsTextAttachment.image = viewsImage;
    [allTimesViewsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:allTimesViewsTextAttachment] atIndex:0];
    [allTimesViewsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    self.allTimeViewsLabel.attributedText = allTimesViewsText;
    self.allTimeViewsLabel.textColor = [WPStyleGuide greyDarken20];

    NSMutableAttributedString *allTimesVisitorsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Visitors", @"Stats Visitors label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *allTimesVisitorsTextAttachment = [InlineTextAttachment new];
    allTimesVisitorsTextAttachment.fontDescender = self.allTimeVisitorsLabel.font.descender;
    allTimesVisitorsTextAttachment.image = visitorsImage;
    [allTimesVisitorsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:allTimesVisitorsTextAttachment] atIndex:0];
    [allTimesVisitorsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    self.allTimeVisitorsLabel.attributedText = allTimesVisitorsText;
    self.allTimeVisitorsLabel.textColor = [WPStyleGuide greyDarken20];
    
    NSMutableAttributedString *allTimesBestViewsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Best Views Ever", @"Stats Best Views label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *allTimesBestViewsTextAttachment = [InlineTextAttachment new];
    allTimesBestViewsTextAttachment.fontDescender = self.allTimeBestViewsLabel.font.descender;
    allTimesBestViewsTextAttachment.image = bestViewsImage;
    [allTimesBestViewsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:allTimesBestViewsTextAttachment] atIndex:0];
    [allTimesBestViewsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    self.allTimeBestViewsLabel.attributedText = allTimesBestViewsText;
    self.allTimeBestViewsLabel.textColor = [WPStyleGuide warningYellow];

    self.todaySectionHeaderLabel.text = NSLocalizedString(@"Today's Stats", @"Insights today section header");
    self.todaySectionHeaderLabel.textColor = [WPStyleGuide greyDarken10];

    self.todayViewsLabel.attributedText = allTimesViewsText;
    self.todayViewsLabel.textColor = [WPStyleGuide greyDarken20];
    
    self.todayVisitorsLabel.attributedText = allTimesVisitorsText;
    self.todayVisitorsLabel.textColor = [WPStyleGuide greyDarken20];
    
    NSMutableAttributedString *likesText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Likes", @"Stats Likes label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *likesTextAttachment = [InlineTextAttachment new];
    likesTextAttachment.fontDescender = self.todayLikesLabel.font.descender;
    likesTextAttachment.image = likesImage;
    [likesText insertAttributedString:[NSAttributedString attributedStringWithAttachment:likesTextAttachment] atIndex:0];
    [likesText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    self.todayLikesLabel.attributedText = likesText;
    self.todayLikesLabel.textColor = [WPStyleGuide greyDarken20];
    
    NSMutableAttributedString *commentsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Comments", @"Stats Comments label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *commentsTextAttachment = [InlineTextAttachment new];
    commentsTextAttachment.fontDescender = self.todayCommentsLabel.font.descender;
    commentsTextAttachment.image = commentsImage;
    [commentsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:commentsTextAttachment] atIndex:0];
    [commentsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    self.todayCommentsLabel.attributedText = commentsText;
    self.todayCommentsLabel.textColor = [WPStyleGuide greyDarken20];
    
    // Default values for no data
    self.mostPopularDay.text = @"--";
    self.mostPopularDay.textColor = [WPStyleGuide greyDarken30];
    self.mostPopularDayPercentWeeklyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of Weekly Views", @"Insights Percent of weekly views label with value"), @"--"];
    self.mostPopularDayPercentWeeklyViews.textColor = [WPStyleGuide greyDarken10];
    self.mostPopularHour.text = @"--";
    self.mostPopularHour.textColor = [WPStyleGuide greyDarken30];
    self.mostPopularHourPercentDailyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of Daily Views", @"Insights Percent of daily views label with value"), @"--"];
    self.mostPopularHourPercentDailyViews.textColor = [WPStyleGuide greyDarken10];
    self.allTimePostsValueLabel.text = @"--";
    self.allTimePostsValueLabel.textColor = [WPStyleGuide greyDarken30];
    self.allTimeViewsValueLabel.text = @"--";
    self.allTimeViewsValueLabel.textColor = [WPStyleGuide greyDarken30];
    self.allTimeVisitorsValueLabel.text = @"--";
    self.allTimeVisitorsValueLabel.textColor = [WPStyleGuide greyDarken30];
    self.allTimeBestViewsValueLabel.text = @"--";
    self.allTimeBestViewsValueLabel.textColor = [WPStyleGuide greyDarken30];
    self.allTimeBestViewsOnValueLabel.text = NSLocalizedString(@"Unknown", @"Unknown data in value label");
    self.allTimeBestViewsOnValueLabel.textColor = [WPStyleGuide greyDarken10];
    self.todayViewsValueLabel.text = @"--";
    self.todayViewsValueLabel.textColor = [WPStyleGuide grey];
    self.todayVisitorsValueLabel.text = @"--";
    self.todayVisitorsValueLabel.textColor = [WPStyleGuide grey];
    self.todayLikesValueLabel.text = @"--";
    self.todayLikesValueLabel.textColor = [WPStyleGuide grey];
    self.todayCommentsValueLabel.text = @"--";
    self.todayCommentsValueLabel.textColor = [WPStyleGuide grey];

    [self retrieveStats];
}



#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        if ([self.statsTypeSelectionDelegate conformsToProtocol:@protocol(WPStatsTypeSelectionDelegate)]) {
            [self.statsTypeSelectionDelegate viewController:self changeStatsTypeSelection:StatsTypeDays];
        }
    }
}

- (IBAction)refreshCurrentStats:(UIRefreshControl *)sender
{
    [self.statsService expireAllItemsInCache];
    [self retrieveStats];
}


- (void)retrieveStats
{
    if ([self.statsProgressViewDelegate respondsToSelector:@selector(statsViewControllerDidBeginLoadingStats:)]
        && self.refreshControl.isRefreshing == NO) {
        self.refreshControl = nil;
    }
    
    __block StatsAllTime *statsAllTime;
    __block StatsInsights *statsInsights;
    __block StatsSummary *todaySummary;
    [self.statsService retrieveInsightsStatsWithAllTimeStatsCompletionHandler:^(StatsAllTime *allTime, NSError *error)
     {
         statsAllTime = allTime;
     }
                                                    insightsCompletionHandler:^(StatsInsights *insights, NSError *error)
     {
         statsInsights = insights;
     }
                                                todaySummaryCompletionHandler:^(StatsSummary *summary, NSError *error)
     {
         todaySummary = summary;
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
         self.mostPopularDay.text = statsInsights.highestDayOfWeek;
         self.mostPopularDayPercentWeeklyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of Weekly Views", @"Insights Percent of weekly views label with value"), statsInsights.highestDayPercent];
         self.mostPopularHour.text = statsInsights.highestHour;
         self.mostPopularHourPercentDailyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of Daily Views", @"Insights Percent of daily views label with value"), statsInsights.highestHourPercent];
         self.allTimePostsValueLabel.text = statsAllTime.numberOfPosts;
         self.allTimeViewsValueLabel.text = statsAllTime.numberOfViews;
         self.allTimeVisitorsValueLabel.text = statsAllTime.numberOfVisitors;
         self.allTimeBestViewsValueLabel.text = statsAllTime.bestNumberOfViews;
         self.allTimeBestViewsOnValueLabel.text = statsAllTime.bestViewsOn;
         self.todayViewsValueLabel.text = todaySummary.views;
         self.todayViewsValueLabel.textColor = todaySummary.viewsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue];
         self.todayVisitorsValueLabel.text = todaySummary.visitors;
         self.todayVisitorsValueLabel.textColor = todaySummary.visitorsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue];
         self.todayLikesValueLabel.text = todaySummary.likes;
         self.todayLikesValueLabel.textColor = todaySummary.likesValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue];
         self.todayCommentsValueLabel.text = todaySummary.comments;
         self.todayCommentsValueLabel.textColor = todaySummary.commentsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue];
         
         [self setupRefreshControl];
         [self.refreshControl endRefreshing];
         
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

@end

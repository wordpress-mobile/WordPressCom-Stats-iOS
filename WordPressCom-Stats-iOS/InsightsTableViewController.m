#import "InsightsTableViewController.h"
#import "WPFontManager+Stats.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"
#import "StatsGaugeView.h"

@interface InsightsTableViewController ()

// Most popular section
@property (nonatomic, weak) IBOutlet UILabel *popularSectionHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *popularPercentViewsLabel;
@property (nonatomic, weak) IBOutlet UILabel *highestTimeLabel;
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
@property (nonatomic, weak) IBOutlet UILabel *percentValueLabel;
@property (nonatomic, weak) IBOutlet StatsGaugeView *gaugeView;
@property (nonatomic, weak) IBOutlet UILabel *percentOnValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *highestTimeValueLabel;
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
    
    self.popularSectionHeaderLabel.text = NSLocalizedString(@"Most popular Day and Time", @"Insights popular section header");
    self.popularPercentViewsLabel.text = [NSLocalizedString(@"Views", @"Stats Views label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.highestTimeLabel.text = NSLocalizedString(@"hour with most Views", @"Stats Highest Hour Views label");
    self.allTimeSectionHeaderLabel.text = NSLocalizedString(@"All-time posts, views, and visitors", @"Insights all time section header");
    self.allTimePostsLabel.text = [NSLocalizedString(@"Posts", @"Stats Posts label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.allTimeViewsLabel.text = [NSLocalizedString(@"Views", @"Stats Views label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.allTimeVisitorsLabel.text = [NSLocalizedString(@"Visitors", @"Stats Visitors label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.allTimeBestViewsLabel.text = [NSLocalizedString(@"Best Views Ever", @"Stats Best Views label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.todaySectionHeaderLabel.text = NSLocalizedString(@"Today's Stats", @"Insights today section header");
    self.todayViewsLabel.text = [NSLocalizedString(@"Views", @"Stats Views label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.todayVisitorsLabel.text = [NSLocalizedString(@"Visitors", @"Stats Visitors label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.todayLikesLabel.text = [NSLocalizedString(@"Likes", @"Stats Likes label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.todayCommentsLabel.text = [NSLocalizedString(@"Comments", @"Stats Comments label") uppercaseStringWithLocale:[NSLocale currentLocale]];
    
    // Default values for no data
    self.percentValueLabel.text = @"--";
    self.gaugeView.percentageFilled = 0.0f;
    self.percentOnValueLabel.text = @"";
    self.highestTimeValueLabel.text = @"--";
    self.allTimePostsValueLabel.text = @"--";
    self.allTimeViewsValueLabel.text = @"--";
    self.allTimeVisitorsValueLabel.text = @"--";
    self.allTimeBestViewsValueLabel.text = @"--";
    self.allTimeBestViewsOnValueLabel.text = NSLocalizedString(@"Unknown", @"Unknown data in value label");
    self.todayViewsValueLabel.text = @"--";
    self.todayVisitorsValueLabel.text = @"--";
    self.todayLikesValueLabel.text = @"--";
    self.todayCommentsValueLabel.text = @"--";

//    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName : [WPFontManager openSansRegularFontOfSize:10.0f]}];
//
//    // All Time Posts label
//    NSMutableAttributedString *allTimePosts = [[NSMutableAttributedString alloc] init];
//    NSAttributedString *postsIcon = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [WPFontManager noticonsReguarFontOfSize:16.0f], NSBaselineOffsetAttributeName : @(-4.0f)}];
//    NSAttributedString *postsLabel = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"Posts", @"Posts label") uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSFontAttributeName : [WPFontManager openSansRegularFontOfSize:10.0f]}];
//    [allTimePosts appendAttributedString:postsIcon];
//    [allTimePosts appendAttributedString:postsLabel];
//    self.allTimePostsLabel.attributedText = allTimePosts;
//    
//    // All Time Views label
//    NSMutableAttributedString *allTimeViews = [[NSMutableAttributedString alloc] init];
//    NSAttributedString *viewsIcon = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [WPFontManager noticonsReguarFontOfSize:16.0f], NSBaselineOffsetAttributeName : @(-4.0f)}];
//    NSAttributedString *viewsLabel = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"Views", @"Views label") uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSFontAttributeName : [WPFontManager openSansRegularFontOfSize:10.0f]}];
//    [allTimeViews appendAttributedString:viewsIcon];
//    [allTimeViews appendAttributedString:space];
//    [allTimeViews appendAttributedString:viewsLabel];
//    self.allTimeViewsLabel.attributedText = allTimeViews;
//
//    // All Time Visitors label
//    NSMutableAttributedString *allTimeVisitors = [[NSMutableAttributedString alloc] init];
//    NSAttributedString *visitorsIcon = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [WPFontManager noticonsReguarFontOfSize:16.0f], NSBaselineOffsetAttributeName : @(-4.0f)}];
//    NSAttributedString *visitorsLabel = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"Visitors", @"Visitors label") uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSFontAttributeName : [WPFontManager openSansRegularFontOfSize:10.0f]}];
//    [allTimeVisitors appendAttributedString:visitorsIcon];
//    [allTimeVisitors appendAttributedString:visitorsLabel];
//    self.allTimeVisitorsLabel.attributedText = allTimeVisitors;
//
//    // All Time Best Views label
//    NSMutableAttributedString *allTimeBestViews = [[NSMutableAttributedString alloc] init];
//    NSAttributedString *bestViewsIcon = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [WPFontManager noticonsReguarFontOfSize:16.0f], NSBaselineOffsetAttributeName : @(-4.0f)}];
//    NSAttributedString *bestViewsLabel = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"Best Views Ever", @"Best Views Ever label") uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSFontAttributeName : [WPFontManager openSansRegularFontOfSize:10.0f]}];
//    [allTimeBestViews appendAttributedString:bestViewsIcon];
//    [allTimeBestViews appendAttributedString:space];
//    [allTimeBestViews appendAttributedString:bestViewsLabel];
//    self.allTimeBestViewsLabel.attributedText = allTimeBestViews;
    [self retrieveStats];
}

- (void)retrieveStats
{
    __block StatsAllTime *statsAllTime;
    __block StatsInsights *statsInsights;
    [self.statsService retrieveInsightsStatsWithAllTimeStatsCompletionHandler:^(StatsAllTime *allTime, NSError *error)
     {
         statsAllTime = allTime;
     }
                                                    insightsCompletionHandler:^(StatsInsights *insights, NSError *error)
     {
         statsInsights = insights;
     }
                                                                progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
     {
         
     }
                                                  andOverallCompletionHandler:^
     {
         self.percentValueLabel.text = statsInsights.highestDayPercent;
         self.gaugeView;
         self.percentOnValueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"happen on a %@", @"Stats most popular on a day - parameter is a day"), statsInsights.highestDayOfWeek];
         self.highestTimeValueLabel.text = statsInsights.highestHour;
         self.allTimePostsValueLabel.text = statsAllTime.numberOfPosts;
         self.allTimeViewsValueLabel.text = statsAllTime.numberOfViews;
         self.allTimeVisitorsValueLabel.text = statsAllTime.numberOfVisitors;
         self.allTimeBestViewsValueLabel.text = statsAllTime.bestNumberOfViews;
         self.allTimeBestViewsOnValueLabel.text = statsAllTime.bestViewsOn;
         self.todayViewsValueLabel.text = nil;
         self.todayVisitorsValueLabel.text = nil;
         self.todayLikesValueLabel.text = nil;
         self.todayCommentsValueLabel.text = nil;
     }];
}

@end

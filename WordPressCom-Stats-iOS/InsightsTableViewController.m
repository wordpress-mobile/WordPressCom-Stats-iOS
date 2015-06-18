#import "InsightsTableViewController.h"
#import "WPFontManager+Stats.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"
#import "StatsGaugeView.h"

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
@property (nonatomic, weak) IBOutlet UIButton *todayViewsButton;
@property (nonatomic, weak) IBOutlet UIButton *todayVisitorsButton;
@property (nonatomic, weak) IBOutlet UIButton *todayLikesButton;
@property (nonatomic, weak) IBOutlet UIButton *todayCommentsButton;

// Values
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDay;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHour;
@property (nonatomic, weak) IBOutlet UILabel *allTimePostsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsOnValueLabel;
@property (nonatomic, weak) IBOutlet UIButton *todayViewsValueButton;
@property (nonatomic, weak) IBOutlet UIButton *todayVisitorsValueButton;
@property (nonatomic, weak) IBOutlet UIButton *todayLikesValueButton;
@property (nonatomic, weak) IBOutlet UIButton *todayCommentsValueButton;

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
    
    self.allTimePostsLabel.attributedText = [self postsAttributedString];
    self.allTimeViewsLabel.attributedText = [self viewsAttributedString];
    self.allTimeVisitorsLabel.attributedText = [self visitorsAttributedString];
    
    self.allTimeBestViewsLabel.attributedText = [self bestViewsAttributedString];

    self.todaySectionHeaderLabel.text = NSLocalizedString(@"Today's Stats", @"Insights today section header");
    self.todaySectionHeaderLabel.textColor = [WPStyleGuide wordPressBlue];

    [self.todayViewsButton setAttributedTitle:[self viewsAttributedString] forState:UIControlStateNormal];
    [self.todayVisitorsButton setAttributedTitle:[self visitorsAttributedString] forState:UIControlStateNormal];
    [self.todayLikesButton setAttributedTitle:[self likesAttributedString] forState:UIControlStateNormal];
    [self.todayCommentsButton setAttributedTitle:[self commentsAttributedString] forState:UIControlStateNormal];
    
    // Default values for no data
    self.mostPopularDay.text = @"-";
    self.mostPopularDay.textColor = [WPStyleGuide greyLighten20];
    self.mostPopularDayPercentWeeklyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), @"-"];
    self.mostPopularDayPercentWeeklyViews.textColor = [WPStyleGuide greyDarken10];
    self.mostPopularHour.text = @"-";
    self.mostPopularHour.textColor = [WPStyleGuide greyLighten20];
    self.mostPopularHourPercentDailyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), @"-"];
    self.mostPopularHourPercentDailyViews.textColor = [WPStyleGuide greyDarken10];
    self.allTimePostsValueLabel.text = @"-";
    self.allTimePostsValueLabel.textColor = [WPStyleGuide greyLighten20];
    self.allTimeViewsValueLabel.text = @"-";
    self.allTimeViewsValueLabel.textColor = [WPStyleGuide greyLighten20];
    self.allTimeVisitorsValueLabel.text = @"-";
    self.allTimeVisitorsValueLabel.textColor = [WPStyleGuide greyLighten20];
    self.allTimeBestViewsValueLabel.text = @"-";
    self.allTimeBestViewsValueLabel.textColor = [WPStyleGuide greyLighten20];
    self.allTimeBestViewsOnValueLabel.text = NSLocalizedString(@"Unknown", @"Unknown data in value label");
    self.allTimeBestViewsOnValueLabel.textColor = [WPStyleGuide greyLighten20];
    [self.todayViewsValueButton setTitle:@"-" forState:UIControlStateNormal];
    [self.todayViewsValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
    [self.todayVisitorsValueButton setTitle:@"-" forState:UIControlStateNormal];
    [self.todayVisitorsValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
    [self.todayLikesValueButton setTitle:@"-" forState:UIControlStateNormal];
    [self.todayLikesValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];
    [self.todayCommentsValueButton setTitle:@"-" forState:UIControlStateNormal];
    [self.todayCommentsValueButton setTitleColor:[WPStyleGuide greyLighten20] forState:UIControlStateNormal];

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
    [self.statsService expireAllItemsInCacheForInsights];
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
         // Set the colors to what they should be (previous color for unknown data)
         self.mostPopularDay.textColor = [WPStyleGuide greyDarken30];
         self.mostPopularHour.textColor = [WPStyleGuide greyDarken30];
         self.allTimePostsValueLabel.textColor = [WPStyleGuide greyDarken30];
         self.allTimeViewsValueLabel.textColor = [WPStyleGuide greyDarken30];
         self.allTimeVisitorsValueLabel.textColor = [WPStyleGuide greyDarken30];
         self.allTimeBestViewsValueLabel.textColor = [WPStyleGuide greyDarken30];
         self.allTimeBestViewsOnValueLabel.textColor = [WPStyleGuide greyDarken10];

         self.mostPopularDay.text = statsInsights.highestDayOfWeek;
         self.mostPopularDayPercentWeeklyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), statsInsights.highestDayPercent];
         self.mostPopularHour.text = statsInsights.highestHour;
         self.mostPopularHourPercentDailyViews.text = [NSString stringWithFormat:NSLocalizedString(@"%@ of views", @"Insights Percent of views label with value"), statsInsights.highestHourPercent];
         self.allTimePostsValueLabel.text = statsAllTime.numberOfPosts;
         self.allTimeViewsValueLabel.text = statsAllTime.numberOfViews;
         self.allTimeVisitorsValueLabel.text = statsAllTime.numberOfVisitors;
         self.allTimeBestViewsValueLabel.text = statsAllTime.bestNumberOfViews;
         self.allTimeBestViewsOnValueLabel.text = statsAllTime.bestViewsOn;
         [self.todayViewsValueButton setTitle:todaySummary.views forState:UIControlStateNormal];
         [self.todayViewsValueButton setTitleColor:todaySummary.viewsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
         [self.todayVisitorsValueButton setTitle:todaySummary.visitors forState:UIControlStateNormal];
         [self.todayVisitorsValueButton setTitleColor:todaySummary.visitorsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
         [self.todayLikesValueButton setTitle:todaySummary.likes forState:UIControlStateNormal];
         [self.todayLikesValueButton setTitleColor:todaySummary.likesValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
         [self.todayCommentsValueButton setTitle:todaySummary.comments forState:UIControlStateNormal];
         [self.todayCommentsValueButton setTitleColor:todaySummary.commentsValue.integerValue == 0 ? [WPStyleGuide grey] : [WPStyleGuide wordPressBlue] forState:UIControlStateNormal];
         
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

#pragma mark - Attributed String generation methods

- (NSMutableAttributedString *)postsAttributedString
{
    NSMutableAttributedString *postsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Posts", @"Stats Posts label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *postsTextAttachment = [InlineTextAttachment new];
    postsTextAttachment.fontDescender = self.allTimeViewsLabel.font.descender;
    postsTextAttachment.image = [self postsImage];
    [postsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:postsTextAttachment] atIndex:0];
    [postsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [postsText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [postsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, postsText.length)];

    return postsText;
}

- (NSMutableAttributedString *)viewsAttributedString
{
    NSMutableAttributedString *viewsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Views", @"Stats Views label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *viewsTextAttachment = [InlineTextAttachment new];
    viewsTextAttachment.fontDescender = self.allTimeViewsLabel.font.descender;
    viewsTextAttachment.image = [self viewsImage];
    [viewsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:viewsTextAttachment] atIndex:0];
    [viewsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [viewsText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [viewsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, viewsText.length)];

    return viewsText;
}

- (NSMutableAttributedString *)visitorsAttributedString
{
    
    NSMutableAttributedString *visitorsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Visitors", @"Stats Visitors label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *visitorsTextAttachment = [InlineTextAttachment new];
    visitorsTextAttachment.fontDescender = self.allTimeVisitorsLabel.font.descender;
    visitorsTextAttachment.image = [self visitorsImage];
    [visitorsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:visitorsTextAttachment] atIndex:0];
    [visitorsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [visitorsText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [visitorsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, visitorsText.length)];

    return visitorsText;
}

- (NSMutableAttributedString *)bestViewsAttributedString
{
    NSMutableAttributedString *bestViewsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Best Views Ever", @"Stats Best Views label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *bestViewsTextAttachment = [InlineTextAttachment new];
    bestViewsTextAttachment.fontDescender = self.allTimeBestViewsLabel.font.descender;
    bestViewsTextAttachment.image = [self bestViewsImage];
    [bestViewsText insertAttributedString:[NSAttributedString attributedStringWithAttachment:bestViewsTextAttachment] atIndex:0];
    [bestViewsText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [bestViewsText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide warningYellow] range:NSMakeRange(0, bestViewsText.length)];

    return bestViewsText;
}

- (NSMutableAttributedString *)likesAttributedString
{
    NSMutableAttributedString *likesText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Likes", @"Stats Likes label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *likesTextAttachment = [InlineTextAttachment new];
    likesTextAttachment.fontDescender = self.todayLikesButton.titleLabel.font.descender;
    likesTextAttachment.image = [self likesImage];
    [likesText insertAttributedString:[NSAttributedString attributedStringWithAttachment:likesTextAttachment] atIndex:0];
    [likesText insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    [likesText appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    [likesText addAttribute:NSForegroundColorAttributeName value:[WPStyleGuide greyDarken20] range:NSMakeRange(0, likesText.length)];

    return likesText;
}

- (NSMutableAttributedString *)commentsAttributedString
{
    NSMutableAttributedString *commentsText = [[NSMutableAttributedString alloc] initWithString:[NSLocalizedString(@"Comments", @"Stats Comments label") uppercaseStringWithLocale:[NSLocale currentLocale]]];
    InlineTextAttachment *commentsTextAttachment = [InlineTextAttachment new];
    commentsTextAttachment.fontDescender = self.todayCommentsButton.titleLabel.font.descender;
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

@end

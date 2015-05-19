#import "InsightsTableViewController.h"
#import "WPFontManager+Stats.h"
#import "WPStyleGuide+Stats.h"
#import "StatsTableSectionHeaderView.h"

@interface InsightsTableViewController ()

@property (nonatomic, weak) IBOutlet UILabel *allTimePostsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsLabel;

@end

@implementation InsightsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
    self.tableView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

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
    
}

@end
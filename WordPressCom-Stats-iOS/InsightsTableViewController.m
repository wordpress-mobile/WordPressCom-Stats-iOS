#import "InsightsTableViewController.h"
#import "WPFontManager+Stats.h"

@interface InsightsTableViewController ()

@property (nonatomic, weak) IBOutlet UILabel *allTimePostsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsLabel;

@end

@implementation InsightsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableAttributedString *allTimePosts = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *postsIcon = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [WPFontManager noticonsReguarFontOfSize:16.0f], NSBaselineOffsetAttributeName : @(-4.0f)}];
    NSAttributedString *postsLabel = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"Posts", @"Posts label") uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSFontAttributeName : [WPFontManager openSansRegularFontOfSize:10.0f]}];
    [allTimePosts appendAttributedString:postsIcon];
    [allTimePosts appendAttributedString:postsLabel];
    self.allTimePostsLabel.attributedText = allTimePosts;
}

@end

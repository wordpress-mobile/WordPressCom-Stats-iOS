#import "WPStatsViewController.h"
#import "StatsTableViewController.h"

@interface WPStatsViewController ()

@end

@implementation WPStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    StatsTableViewController *statsViewController = (StatsTableViewController *)[self topViewController];
    statsViewController.siteID = self.siteID;
    statsViewController.siteTimeZone = self.siteTimeZone;
    statsViewController.oauth2Token = self.oauth2Token;
    statsViewController.statsDelegate = self.statsDelegate;
}

@end

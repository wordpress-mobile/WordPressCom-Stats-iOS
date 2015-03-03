#import "WPStatsViewController.h"
#import "StatsTableViewController.h"

@interface WPStatsViewController () <StatsTableViewControllerDelegate>

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;
@property (nonatomic, weak) IBOutlet UISegmentedControl *periodSegmentControl;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation WPStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.periodSegmentControl setTitle:NSLocalizedString(@"Days", @"") forSegmentAtIndex:0];
    [self.periodSegmentControl setTitle:NSLocalizedString(@"Weeks", @"") forSegmentAtIndex:1];
    [self.periodSegmentControl setTitle:NSLocalizedString(@"Months", @"") forSegmentAtIndex:2];
    [self.periodSegmentControl setTitle:NSLocalizedString(@"Years", @"") forSegmentAtIndex:3];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    StatsTableViewController *tableVC = (StatsTableViewController *)segue.destinationViewController;
    self.statsTableViewController = tableVC;
    tableVC.oauth2Token = self.oauth2Token;
    tableVC.siteID = self.siteID;
    tableVC.siteTimeZone = self.siteTimeZone;
    tableVC.statsDelegate = self.statsDelegate;
    tableVC.statsTableDelegate = self;
}

- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control
{
    [self.statsTableViewController periodUnitControlDidChange:control];
}


#pragma mark StatsTableViewControllerDelegate methods


- (void)statsTableViewControllerDidBeginLoadingStats:(StatsTableViewController *)controller
{
    [self.activityIndicatorView startAnimating];
}


- (void)statsTableViewControllerDidEndLoadingStats:(StatsTableViewController *)controller
{
    [self.activityIndicatorView stopAnimating];
}

@end

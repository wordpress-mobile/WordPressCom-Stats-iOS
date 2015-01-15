#import "WPStatsContainerViewController.h"
#import "WPStatsViewController.h"
#import "StatsTableViewController.h"

@interface WPStatsContainerViewController ()

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;

@end

@implementation WPStatsContainerViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    WPStatsViewController *statsVC = (WPStatsViewController *)self.parentViewController;
    StatsTableViewController *tableVC = (StatsTableViewController *)segue.destinationViewController;
    self.statsTableViewController = tableVC;
    tableVC.oauth2Token = statsVC.oauth2Token;
    tableVC.siteID = statsVC.siteID;
    tableVC.siteTimeZone = statsVC.siteTimeZone;
    tableVC.statsDelegate = statsVC.statsDelegate;
}

- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control
{
    [self.statsTableViewController periodUnitControlDidChange:control];
}


@end

#import "WPStatsViewController.h"
#import "StatsTableViewController.h"

@interface WPStatsViewController () <StatsTableViewControllerDelegate>

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;
@property (nonatomic, weak) IBOutlet UISegmentedControl *periodSegmentControl;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, assign) NSUInteger numberOfSteps;

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


- (void)statsTableViewController:(UIViewController *)controller didBeginLoadingStatsWithTotalNumberOfProgressSteps:(NSUInteger)steps
{
    self.numberOfSteps = steps;
    self.progressView.progress = 0.0f;
    self.progressView.hidden = NO;
}

- (void)statsTableViewController:(UIViewController *)controller didFinishNumberOfLoadingSteps:(NSUInteger)steps
{
    float progress = (float)steps / (float)self.numberOfSteps;
    [self.progressView setProgress:progress animated:YES];
}

- (void)statsTableViewControllerDidEndLoadingStats:(StatsTableViewController *)controller
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.progressView.alpha = 0.0f;
        }
                         completion:^(BOOL finished) {
                             self.progressView.alpha = 1.0f;
                             self.progressView.hidden = YES;
                         }];
    });
}

@end

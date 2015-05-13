#import "WPStatsViewController.h"
#import "StatsTableViewController.h"

@interface WPStatsViewController () <StatsTableViewControllerDelegate>

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;
@property (nonatomic, weak) IBOutlet UISegmentedControl *statsTypeSegmentControl;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIView *insightsContainerView;
@property (nonatomic, weak) IBOutlet UIView *statsContainerView;

@end

@implementation WPStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPAD) {
        // Don't do anything
        [self.statsTypeSegmentControl removeAllSegments];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Insights", @"Title of Insights segmented control") atIndex:0 animated:NO];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Days", @"") atIndex:1 animated:NO];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Weeks", @"") atIndex:2 animated:NO];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Months", @"") atIndex:3 animated:NO];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Years", @"") atIndex:4 animated:NO];
    } else {
        [self.statsTypeSegmentControl removeAllSegments];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Insights", @"Title of Insights segmented control") atIndex:0 animated:NO];
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Details", @"Title of Details segmented control") atIndex:1 animated:NO];
    }

    self.statsTypeSegmentControl.selectedSegmentIndex = 0;
    self.insightsContainerView.hidden = NO;
    self.statsContainerView.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"StatsTableEmbed"]) {
        StatsTableViewController *tableVC = (StatsTableViewController *)segue.destinationViewController;
        self.statsTableViewController = tableVC;
        tableVC.oauth2Token = self.oauth2Token;
        tableVC.siteID = self.siteID;
        tableVC.siteTimeZone = self.siteTimeZone;
        tableVC.statsDelegate = self.statsDelegate;
        tableVC.statsTableDelegate = self;
    }
}

- (IBAction)statsTypeControlDidChange:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0) {
        self.insightsContainerView.hidden = NO;
        self.statsContainerView.hidden = YES;
    } else {
        self.insightsContainerView.hidden = YES;
        self.statsContainerView.hidden = NO;
    }
}


#pragma mark StatsTableViewControllerDelegate methods


- (void)statsTableViewControllerDidBeginLoadingStats:(UIViewController *)controller
{
    self.progressView.progress = 0.03f;
    self.progressView.hidden = NO;
}

- (void)statsTableViewController:(UIViewController *)controller loadingProgressPercentage:(CGFloat)percentage
{
    self.progressView.hidden = NO;
    [self.progressView setProgress:percentage animated:YES];
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

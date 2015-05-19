#import "WPStatsViewController.h"
#import "StatsTableViewController.h"


typedef NS_ENUM(NSInteger, StatsType)
{
    StatsTypeInsights,
    StatsTypeDays,
    StatsTypeWeeks,
    StatsTypeMonths,
    StatsTypeYears
};

@interface WPStatsViewController () <StatsTableViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;
@property (nonatomic, weak) IBOutlet UISegmentedControl *statsTypeSegmentControl;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIView *insightsContainerView;
@property (nonatomic, weak) IBOutlet UIView *statsContainerView;
@property (nonatomic, weak) UIActionSheet *periodActionSheet;

@property (nonatomic, assign) StatsType lastSelectedStatsType;
@property (nonatomic, assign) StatsType statsType;
@property (nonatomic, assign) BOOL showingAbbreviatedSegments;

@end

@implementation WPStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statsType = StatsTypeInsights;
    self.lastSelectedStatsType = StatsTypeDays;

    if (IS_IPAD || UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self showAllSegments];
        self.showingAbbreviatedSegments = NO;
    } else {
        [self showAbbreviatedSegments];
        self.showingAbbreviatedSegments = YES;
    }

    self.statsTypeSegmentControl.selectedSegmentIndex = self.statsType;
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

#pragma mark UIViewController overrides

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.periodActionSheet dismissWithClickedButtonIndex:self.periodActionSheet.cancelButtonIndex animated:YES];
    [self updateSegmentedControl];
}


#pragma mark Actions

- (IBAction)statsTypeControlDidChange:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0) {
        self.statsType = StatsTypeInsights;
        self.insightsContainerView.hidden = NO;
        self.statsContainerView.hidden = YES;
        return;
    }

    self.insightsContainerView.hidden = YES;
    self.statsContainerView.hidden = NO;
    
    if (self.showingAbbreviatedSegments && control.selectedSegmentIndex == 2) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Period Unit"
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button title")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Days", @"Title of Days segmented control"), NSLocalizedString(@"Weeks", @"Title of Weeks segmented control"), NSLocalizedString(@"Months", @"Title of Months segmented control"), NSLocalizedString(@"Years", @"Title of Years segmented control"), nil];
        UIViewController *viewController = [[[UIApplication sharedApplication] windows].firstObject rootViewController];
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            [actionSheet showFromTabBar:[(UITabBarController *)viewController tabBar]];
        } else {
            [actionSheet showInView:viewController.view];
        }
        self.periodActionSheet = actionSheet;
    } else {
        self.statsType = control.selectedSegmentIndex;
        self.lastSelectedStatsType = self.statsType;
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


#pragma mark - UIActionSheetDelegate methods


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    self.statsType = buttonIndex + 1;
    self.lastSelectedStatsType = self.statsType;
    [self showAbbreviatedSegments];
}


#pragma mark - Private methods

- (void)updateSegmentedControl
{
    if (IS_IPHONE == NO) {
        return;
    }
    
    // If rotated from landscape to portrait
    BOOL wasShowingAbbreviatedSegments = self.showingAbbreviatedSegments;
    self.showingAbbreviatedSegments = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    if (self.showingAbbreviatedSegments && wasShowingAbbreviatedSegments == NO) {
        [self showAbbreviatedSegments];
        
    } else if (wasShowingAbbreviatedSegments && self.showingAbbreviatedSegments == NO) {
        [self showAllSegments];
    }
}

- (void)showAbbreviatedSegments
{
    [self.statsTypeSegmentControl removeAllSegments];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Insights", @"Title of Insights segmented control") atIndex:0 animated:NO];
    
    if (self.lastSelectedStatsType == StatsTypeDays) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Days", @"Title of Days segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedStatsType == StatsTypeWeeks) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Weeks", @"Title of Weeks segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedStatsType == StatsTypeMonths) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Months", @"Title of Months segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedStatsType == StatsTypeYears) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Years", @"Title of Years segmented control") atIndex:1 animated:NO];
    }
    
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"...", @"Title of more periods segmented control") atIndex:2 animated:NO];
    
    if (self.statsType == StatsTypeInsights) {
        self.statsTypeSegmentControl.selectedSegmentIndex = 0;
    } else {
        self.statsTypeSegmentControl.selectedSegmentIndex = 1;
    }
}

- (void)showAllSegments
{
    [self.statsTypeSegmentControl removeAllSegments];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Insights", @"Title of Insights segmented control") atIndex:0 animated:NO];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Days", @"Title of Days segmented control") atIndex:1 animated:NO];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Weeks", @"Title of Weeks segmented control") atIndex:2 animated:NO];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Months", @"Title of Months segmented control") atIndex:3 animated:NO];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Years", @"Title of Years segmented control") atIndex:4 animated:NO];
    
    self.statsTypeSegmentControl.selectedSegmentIndex = self.statsType;
}

@end

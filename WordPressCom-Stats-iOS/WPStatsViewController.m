#import "WPStatsViewController.h"
#import "StatsTableViewController.h"
#import "WPStatsService.h"
#import "InsightsTableViewController.h"

@interface WPStatsViewController () <StatsProgressViewDelegate, WPStatsSummaryTypeSelectionDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;
@property (nonatomic, weak) InsightsTableViewController *insightsTableViewController;
@property (nonatomic, weak) IBOutlet UISegmentedControl *statsTypeSegmentControl;
@property (nonatomic, weak) IBOutlet UIProgressView *insightsProgressView;
@property (nonatomic, weak) IBOutlet UIProgressView *statsProgressView;
@property (nonatomic, weak) IBOutlet UIView *insightsContainerView;
@property (nonatomic, weak) IBOutlet UIView *statsContainerView;
@property (nonatomic, weak) UIActionSheet *periodActionSheet;

@property (nonatomic, assign) StatsPeriodType lastSelectedStatsPeriodType;
@property (nonatomic, assign) StatsPeriodType statsPeriodType;
@property (nonatomic, assign) BOOL showingAbbreviatedSegments;

@end

@implementation WPStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statsPeriodType = StatsPeriodTypeInsights;
    self.lastSelectedStatsPeriodType = StatsPeriodTypeDays;

    if (IS_IPAD || UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self showAllSegments];
        self.showingAbbreviatedSegments = NO;
    } else {
        [self showAbbreviatedSegments];
        self.showingAbbreviatedSegments = YES;
    }

    self.statsTypeSegmentControl.selectedSegmentIndex = self.statsPeriodType;
    self.insightsContainerView.hidden = NO;
    self.statsContainerView.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"StatsTableEmbed"]) {
        StatsTableViewController *tableVC = (StatsTableViewController *)segue.destinationViewController;
        self.statsTableViewController = tableVC;
        tableVC.statsDelegate = self.statsDelegate;
        tableVC.statsProgressViewDelegate = self;
        tableVC.statsService = [[WPStatsService alloc] initWithSiteId:self.siteID siteTimeZone:self.siteTimeZone oauth2Token:self.oauth2Token andCacheExpirationInterval:5 * 60];
;
    } else if ([segue.identifier isEqualToString:@"InsightsTableEmbed"]) {
        InsightsTableViewController *insightsTableViewController = (InsightsTableViewController *)segue.destinationViewController;
        self.insightsTableViewController = insightsTableViewController;
        insightsTableViewController.statsService = [[WPStatsService alloc] initWithSiteId:self.siteID siteTimeZone:self.siteTimeZone oauth2Token:self.oauth2Token andCacheExpirationInterval:5 * 60];
        insightsTableViewController.statsProgressViewDelegate = self;
        insightsTableViewController.statsTypeSelectionDelegate = self;
        insightsTableViewController.statsDelegate = self.statsDelegate;
    }
}

#pragma mark UIViewController overrides

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.periodActionSheet dismissWithClickedButtonIndex:self.periodActionSheet.cancelButtonIndex animated:YES];
    [self updateSegmentedControlForceUpdate:NO];
}


#pragma mark Actions

- (IBAction)statsTypeControlDidChange:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0) {
        self.statsPeriodType = StatsPeriodTypeInsights;
        self.insightsContainerView.hidden = NO;
        if (self.insightsProgressView.progress > 0.0f) {
            self.insightsProgressView.hidden = NO;
        }
        self.statsContainerView.hidden = YES;
        self.statsProgressView.hidden = YES;
        return;
    }
    
    if (self.showingAbbreviatedSegments && control.selectedSegmentIndex == 2) {
#ifndef AF_APP_EXTENSIONS
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
#endif
    } else {
        self.insightsContainerView.hidden = YES;
        self.insightsProgressView.hidden = YES;
        self.statsContainerView.hidden = NO;
        if (self.statsProgressView.progress > 0.0f) {
            self.statsProgressView.hidden = NO;
        }
   
        if (self.showingAbbreviatedSegments && control.selectedSegmentIndex == 1) {
            self.statsPeriodType = self.lastSelectedStatsPeriodType;
        } else {
            self.statsPeriodType = control.selectedSegmentIndex;
            self.lastSelectedStatsPeriodType = self.statsPeriodType;
        }
    }
    
}


#pragma mark WPStatsSummaryTypeSelectionDelegate methods

- (void)viewController:(UIViewController *)viewController changeStatsSummaryTypeSelection:(StatsSummaryType)statsSummaryType
{
    self.lastSelectedStatsPeriodType = StatsPeriodTypeDays;
    self.statsPeriodType = StatsPeriodTypeDays;
    
    [self updateSegmentedControlForceUpdate:YES];

    self.insightsContainerView.hidden = YES;
    self.insightsProgressView.hidden = YES;
    self.statsContainerView.hidden = NO;
    if (self.statsProgressView.progress > 0.0f) {
        self.statsProgressView.hidden = NO;
    }
    
    [self.statsTableViewController switchToSummaryType:statsSummaryType];
}

#pragma mark StatsTableViewControllerDelegate methods


- (void)statsViewControllerDidBeginLoadingStats:(UIViewController *)controller
{
    UIProgressView *progressView = nil;
    BOOL controllerIsVisible = NO;
    if (controller == self.insightsTableViewController) {
        progressView = self.insightsProgressView;
        controllerIsVisible = self.statsPeriodType == StatsPeriodTypeInsights;
    } else if (controller == self.statsTableViewController) {
        progressView = self.statsProgressView;
        controllerIsVisible = self.statsPeriodType != StatsPeriodTypeInsights;
    }
    
    if (controllerIsVisible) {
        progressView.hidden = NO;
    }

    progressView.progress = 0.03f;
}

- (void)statsViewController:(UIViewController *)controller loadingProgressPercentage:(CGFloat)percentage
{
    UIProgressView *progressView = nil;
    BOOL controllerIsVisible = NO;
    if (controller == self.insightsTableViewController) {
        progressView = self.insightsProgressView;
        controllerIsVisible = self.statsPeriodType == StatsPeriodTypeInsights;
    } else if (controller == self.statsTableViewController) {
        progressView = self.statsProgressView;
        controllerIsVisible = self.statsPeriodType != StatsPeriodTypeInsights;
    }
    
    if (controllerIsVisible) {
        progressView.hidden = NO;
    }
    
    [progressView setProgress:(float)percentage animated:YES];
}

- (void)statsViewControllerDidEndLoadingStats:(UIViewController *)controller
{
    UIProgressView *progressView = nil;
    if (controller == self.insightsTableViewController) {
        progressView = self.insightsProgressView;
    } else if (controller == self.statsTableViewController) {
        progressView = self.statsProgressView;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            progressView.alpha = 0.0f;
        }
                         completion:^(BOOL finished) {
                             progressView.alpha = 1.0f;
                             progressView.hidden = YES;
                             progressView.progress = 0.0f;
                         }];
    });
}


#pragma mark - UIActionSheetDelegate methods


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        // If last selected was Insights, reselect it otherwise force segment 1
        self.statsTypeSegmentControl.selectedSegmentIndex = self.statsPeriodType == StatsPeriodTypeInsights ? StatsPeriodTypeInsights : 1;
        return;
    }
    
    self.statsPeriodType = buttonIndex + 1;
    self.lastSelectedStatsPeriodType = self.statsPeriodType;
    [self showAbbreviatedSegments];
}


#pragma mark - Private methods

- (void)updateSegmentedControlForceUpdate:(BOOL)forceUpdate
{
    if (IS_IPHONE == NO) {
        return;
    }
    
    // If rotated from landscape to portrait
    BOOL wasShowingAbbreviatedSegments = self.showingAbbreviatedSegments;
    self.showingAbbreviatedSegments = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    if (self.showingAbbreviatedSegments && (wasShowingAbbreviatedSegments == NO || forceUpdate)) {
        [self showAbbreviatedSegments];
        
    } else if ((wasShowingAbbreviatedSegments || forceUpdate) && self.showingAbbreviatedSegments == NO) {
        [self showAllSegments];
    }
}

- (void)showAbbreviatedSegments
{
    [self.statsTypeSegmentControl removeAllSegments];
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Insights", @"Title of Insights segmented control") atIndex:0 animated:NO];
    
    if (self.lastSelectedStatsPeriodType == StatsPeriodTypeDays) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Days", @"Title of Days segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedStatsPeriodType == StatsPeriodTypeWeeks) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Weeks", @"Title of Weeks segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedStatsPeriodType == StatsPeriodTypeMonths) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Months", @"Title of Months segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedStatsPeriodType == StatsPeriodTypeYears) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Years", @"Title of Years segmented control") atIndex:1 animated:NO];
    }
    
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"More…", @"Title of more periods segmented control") atIndex:2 animated:NO];
    
    if (self.statsPeriodType == StatsPeriodTypeInsights) {
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
    
    self.statsTypeSegmentControl.selectedSegmentIndex = self.statsPeriodType;
}

- (void)setStatsPeriodType:(StatsPeriodType)statsPeriodType
{
    if (statsPeriodType != StatsPeriodTypeInsights && statsPeriodType != _statsPeriodType) {
        StatsPeriodUnit periodUnit = statsPeriodType - 1;
        [self.statsTableViewController changeGraphPeriod:periodUnit];
        self.statsContainerView.hidden = NO;
        self.insightsContainerView.hidden = YES;
    } else {
        self.statsContainerView.hidden = YES;
        self.insightsContainerView.hidden = NO;
    }
    
    _statsPeriodType = statsPeriodType;
}

@end

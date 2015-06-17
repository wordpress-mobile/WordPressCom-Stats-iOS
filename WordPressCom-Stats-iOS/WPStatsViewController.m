#import "WPStatsViewController.h"
#import "StatsTableViewController.h"
#import "WPStatsService.h"
#import "InsightsTableViewController.h"

@interface WPStatsViewController () <StatsProgressViewDelegate, WPStatsTypeSelectionDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) StatsTableViewController *statsTableViewController;
@property (nonatomic, weak) InsightsTableViewController *insightsTableViewController;
@property (nonatomic, weak) IBOutlet UISegmentedControl *statsTypeSegmentControl;
@property (nonatomic, weak) IBOutlet UIProgressView *insightsProgressView;
@property (nonatomic, weak) IBOutlet UIProgressView *statsProgressView;
@property (nonatomic, weak) IBOutlet UIView *insightsContainerView;
@property (nonatomic, weak) IBOutlet UIView *statsContainerView;
@property (nonatomic, weak) UIActionSheet *periodActionSheet;

@property (nonatomic, assign) StatsType lastSelectedPeriodStatsType;
@property (nonatomic, assign) StatsType statsType;
@property (nonatomic, assign) BOOL showingAbbreviatedSegments;

@property (nonatomic, strong) WPStatsService *statsService;

@end

@implementation WPStatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statsType = StatsTypeInsights;
    self.lastSelectedPeriodStatsType = StatsTypeDays;

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
        tableVC.statsDelegate = self.statsDelegate;
        tableVC.statsProgressViewDelegate = self;
        tableVC.statsService = self.statsService;
    } else if ([segue.identifier isEqualToString:@"InsightsTableEmbed"]) {
        InsightsTableViewController *insightsTableViewController = (InsightsTableViewController *)segue.destinationViewController;
        self.insightsTableViewController = insightsTableViewController;
        insightsTableViewController.statsService = self.statsService;
        insightsTableViewController.statsProgressViewDelegate = self;
        insightsTableViewController.statsTypeSelectionDelegate = self;
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
        self.statsType = StatsTypeInsights;
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
            self.statsType = self.lastSelectedPeriodStatsType;
        } else {
            self.statsType = control.selectedSegmentIndex;
            self.lastSelectedPeriodStatsType = self.statsType;
        }
    }
    
}


#pragma mark WPStatsTypeSelectionDelegate methods

- (void)viewController:(UIViewController *)viewController changeStatsTypeSelection:(StatsType)statsType
{
    self.lastSelectedPeriodStatsType = statsType;
    self.statsType = statsType;

    [self updateSegmentedControlForceUpdate:YES];

    self.insightsContainerView.hidden = YES;
    self.insightsProgressView.hidden = YES;
    self.statsContainerView.hidden = NO;
    if (self.statsProgressView.progress > 0.0f) {
        self.statsProgressView.hidden = NO;
    }
}

#pragma mark StatsTableViewControllerDelegate methods


- (void)statsViewControllerDidBeginLoadingStats:(UIViewController *)controller
{
    UIProgressView *progressView = nil;
    BOOL controllerIsVisible = NO;
    if (controller == self.insightsTableViewController) {
        progressView = self.insightsProgressView;
        controllerIsVisible = self.statsType == StatsTypeInsights;
    } else if (controller == self.statsTableViewController) {
        progressView = self.statsProgressView;
        controllerIsVisible = self.statsType != StatsTypeInsights;
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
        controllerIsVisible = self.statsType == StatsTypeInsights;
    } else if (controller == self.statsTableViewController) {
        progressView = self.statsProgressView;
        controllerIsVisible = self.statsType != StatsTypeInsights;
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
        self.statsTypeSegmentControl.selectedSegmentIndex = self.statsType == StatsTypeInsights ? StatsTypeInsights : 1;
        return;
    }
    
    self.statsType = buttonIndex + 1;
    self.lastSelectedPeriodStatsType = self.statsType;
    [self showAbbreviatedSegments];
}


#pragma mark - Property overrides

- (WPStatsService *)statsService
{
    if (!_statsService) {
        NSTimeInterval fiveMinutes = 60 * 5;
        _statsService = [[WPStatsService alloc] initWithSiteId:self.siteID siteTimeZone:self.siteTimeZone oauth2Token:self.oauth2Token andCacheExpirationInterval:fiveMinutes];
    }
    
    return _statsService;
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
    
    if (self.lastSelectedPeriodStatsType == StatsTypeDays) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Days", @"Title of Days segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedPeriodStatsType == StatsTypeWeeks) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Weeks", @"Title of Weeks segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedPeriodStatsType == StatsTypeMonths) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Months", @"Title of Months segmented control") atIndex:1 animated:NO];
    } else if (self.lastSelectedPeriodStatsType == StatsTypeYears) {
        [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"Years", @"Title of Years segmented control") atIndex:1 animated:NO];
    }
    
    [self.statsTypeSegmentControl insertSegmentWithTitle:NSLocalizedString(@"More…", @"Title of more periods segmented control") atIndex:2 animated:NO];
    
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

- (void)setStatsType:(StatsType)statsType
{
    if (statsType != StatsTypeInsights && statsType != _statsType) {
        StatsPeriodUnit periodUnit = statsType - 1;
        [self.statsTableViewController changeGraphPeriod:periodUnit];
    }
    
    _statsType = statsType;
}

@end

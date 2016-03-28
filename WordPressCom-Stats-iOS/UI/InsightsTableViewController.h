#import <UIKit/UIKit.h>
#import "WPStatsService.h"
#import "WPStatsViewController.h"
#import "WPStatsContributionGraph.h"

@interface InsightsTableViewController : UITableViewController <WPStatsContributionGraphDataSource>

@property (nonatomic, strong) WPStatsService *statsService;
@property (nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;
@property (nonatomic, weak) id<StatsProgressViewDelegate> statsProgressViewDelegate;
@property (nonatomic, weak) id<WPStatsSummaryTypeSelectionDelegate> statsTypeSelectionDelegate;

@end

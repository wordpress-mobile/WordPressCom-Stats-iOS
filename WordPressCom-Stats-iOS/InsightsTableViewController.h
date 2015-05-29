#import <UIKit/UIKit.h>
#import "WPStatsService.h"
#import "WPStatsViewController.h"

@interface InsightsTableViewController : UITableViewController

@property (nonatomic, strong) WPStatsService *statsService;
@property (nonatomic, weak) id<StatsProgressViewDelegate> statsProgressViewDelegate;

@end

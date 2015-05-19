#import <UIKit/UIKit.h>
#import "WPStatsViewController.h"
#import "StatsSummary.h"

@protocol WPStatsViewControllerDelegate;
@class StatsTableViewController;

@protocol StatsTableViewControllerDelegate <NSObject>

- (void)statsTableViewControllerDidBeginLoadingStats:(UIViewController *)controller;
- (void)statsTableViewController:(UIViewController *)controller loadingProgressPercentage:(CGFloat)percentage;
- (void)statsTableViewControllerDidEndLoadingStats:(UIViewController *)controller;

@end


@interface StatsTableViewController : UITableViewController

@property (nonatomic, strong) NSNumber *siteID;
@property (nonatomic, copy)   NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;
@property (nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;
@property (nonatomic, weak) id<StatsTableViewControllerDelegate> statsTableDelegate;

- (void)changeGraphPeriod:(StatsPeriodUnit)toPeriod;

@end

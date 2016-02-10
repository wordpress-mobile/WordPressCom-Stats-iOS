#import <UIKit/UIKit.h>
#import "StatsTableViewController.h"
#import "StatsSummary.h"

typedef NS_ENUM(NSInteger, StatsPeriodType)
{
    StatsPeriodTypeInsights,
    StatsPeriodTypeDays,
    StatsPeriodTypeWeeks,
    StatsPeriodTypeMonths,
    StatsPeriodTypeYears
};

@class WPStatsViewController;
@class WPStatsService;
@class WPStatsServiceCache;

@protocol WPStatsSummaryTypeSelectionDelegate <NSObject>

- (void)viewController:(nonnull UIViewController *)viewController changeStatsSummaryTypeSelection:(StatsSummaryType)statsSummaryType;

@end

@protocol WPStatsViewControllerDelegate <NSObject>

@optional

- (void)statsViewController:(nonnull WPStatsViewController *)controller openURL:(nullable NSURL *)url;

@end

@protocol StatsProgressViewDelegate <NSObject>

- (void)statsViewControllerDidBeginLoadingStats:(nonnull UIViewController *)controller;
- (void)statsViewController:(nonnull UIViewController *)controller loadingProgressPercentage:(CGFloat)percentage;
- (void)statsViewControllerDidEndLoadingStats:(nonnull UIViewController *)controller;

@end

@interface WPStatsViewController : UIViewController

@property (nullable, nonatomic, strong) NSNumber *siteID;
@property (nullable, nonatomic, copy)   NSString *oauth2Token;
@property (nullable, nonatomic, strong) NSTimeZone *siteTimeZone;
@property (nullable, nonatomic, strong) WPStatsServiceCache *statsServiceCache;
@property (nullable, nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;

- (nonnull instancetype)initWithStatsServiceCache:(nullable WPStatsServiceCache *)cache;

- (IBAction)statsTypeControlDidChange:(nonnull UISegmentedControl *)control;

@end

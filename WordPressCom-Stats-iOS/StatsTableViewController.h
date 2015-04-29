#import <UIKit/UIKit.h>
#import "WPStatsViewController.h"

@protocol WPStatsViewControllerDelegate;
@class StatsTableViewController;

@protocol StatsTableViewControllerDelegate <NSObject>

- (void)statsTableViewController:(UIViewController *)controller didBeginLoadingStatsWithTotalNumberOfProgressSteps:(NSUInteger)steps;
- (void)statsTableViewController:(UIViewController *)controller didFinishNumberOfLoadingSteps:(NSUInteger)steps;
- (void)statsTableViewControllerDidEndLoadingStats:(UIViewController *)controller;

@end


@interface StatsTableViewController : UITableViewController

@property (nonatomic, strong) NSNumber *siteID;
@property (nonatomic, copy)   NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;
@property (nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;
@property (nonatomic, weak) id<StatsTableViewControllerDelegate> statsTableDelegate;

- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control;

@end

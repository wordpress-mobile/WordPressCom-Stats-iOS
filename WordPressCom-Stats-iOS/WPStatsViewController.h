#import <UIKit/UIKit.h>
#import "StatsTableViewController.h"

@class WPStatsViewController;
@protocol WPStatsViewControllerDelegate <NSObject>

@optional

- (void)statsViewController:(WPStatsViewController *)controller didSelectViewWebStatsForSiteID:(NSNumber *)siteID;
- (void)statsViewController:(WPStatsViewController *)controller openURL:(NSURL *)url;

@end

@interface WPStatsViewController : UIViewController

@property (nonatomic, strong) NSNumber *siteID;
@property (nonatomic, copy)   NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;
@property (nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;

- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control;

@end

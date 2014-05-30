#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StatsSection) {
    StatsSectionVisitors,
    StatsSectionTopPosts,
    StatsSectionViewsByCountry,
    StatsSectionTotalsFollowersShares,
    StatsSectionClicks,
    StatsSectionReferrers,
    StatsSectionSearchTerms,
    StatsSectionLinkToWebview,
    StatsSectionTotalCount,
    StatsSectionVisitorsGraph   // Not a real section!
};

@protocol WPStatsViewControllerDelegate;

@interface WPStatsViewController : UITableViewController

@property (nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;

- (instancetype)initWithSiteID:(NSNumber *)siteID andOAuth2Token:(NSString *)oauth2Token;

@end

@protocol WPStatsViewControllerDelegate <NSObject>

@optional

- (void)statsViewController:(WPStatsViewController *)statsViewController didSelectViewWebStatsForSiteID:(NSNumber *)siteID;

@end
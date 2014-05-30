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

@protocol StatsViewControllerDelegate;

@interface StatsViewController : UITableViewController

@property (nonatomic, weak) id<StatsViewControllerDelegate> statsDelegate;

- (instancetype)initWithSiteID:(NSNumber *)siteID andOAuth2Token:(NSString *)oauth2Token;

@end

@protocol StatsViewControllerDelegate <NSObject>

@optional

- (void)statsViewController:(StatsViewController *)statsViewController didSelectViewWebStatsForSiteID:(NSNumber *)siteID;

@end
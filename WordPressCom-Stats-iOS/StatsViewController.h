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


@interface StatsViewController : UITableViewController

- (instancetype)initWithSiteID:(NSNumber *)siteID andOAuth2Token:(NSString *)oauth2Token;

@end

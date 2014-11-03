#import "WPStatsService.h"
#import "StatsSummary.h"
#import "StatsVisits.h"

typedef void (^StatsRemoteCompletion)(StatsSummary *summary, NSDictionary *topPosts, NSDictionary *clicks, NSDictionary *countryViews, NSDictionary *referrers, NSDictionary *searchTerms, WPStatsViewsVisitors *viewsVisitors);

@interface WPStatsServiceV2Remote : NSObject

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone;

- (void)fetchStatsForTodayDate:(NSDate *)today andYesterdayDate:(NSDate *)yesterday withCompletionHandler:(StatsCompletion)completionHandler failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchSummaryStatsForTodayWithCompletionHandler:(void (^)(StatsSummary *summary))completionHandler failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchVisitsStatsForPeriodUnit:(StatsPeriodUnit)unit
                withCompletionHandler:(void (^)(StatsVisits *visits))completionHandler
                       failureHandler:(void (^)(NSError *error))failureHandler;

@end

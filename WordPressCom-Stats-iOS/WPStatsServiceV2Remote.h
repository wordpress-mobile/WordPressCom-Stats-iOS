#import "WPStatsService.h"
#import "StatsSummary.h"
#import "StatsVisits.h"

typedef void (^StatsRemoteCompletion)(StatsSummary *summary, NSDictionary *topPosts, NSDictionary *clicks, NSDictionary *countryViews, NSDictionary *referrers, NSDictionary *searchTerms, WPStatsViewsVisitors *viewsVisitors);

@interface WPStatsServiceV2Remote : NSObject

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone;

- (void)fetchSummaryStatsForTodayWithCompletionHandler:(void (^)(StatsSummary *summary))completionHandler
                                        failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchVisitsStatsForPeriodUnit:(StatsPeriodUnit)unit
                withCompletionHandler:(void (^)(StatsVisits *visits))completionHandler
                       failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchPostsStatsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
         withCompletionHandler:(void (^)(NSArray *items, NSNumber *totalViews))completionHandler
                failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchReferrersStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(void (^)(NSArray *items, NSNumber *totalViews, NSNumber *otherViews))completionHandler
                    failureHandler:(void (^)(NSError *error))failureHandler;
@end

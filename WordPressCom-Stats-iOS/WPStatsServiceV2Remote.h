#import "WPStatsService.h"
#import "StatsSummary.h"
#import "StatsVisits.h"

typedef void (^StatsRemoteSummaryCompletion)(StatsSummary *summary);
typedef void (^StatsRemoteVisitsCompletion)(StatsVisits *visits);
typedef void (^StatsRemoteItemsCompletion)(NSArray *items, NSNumber *totalViews, NSNumber *otherViews);


@interface WPStatsServiceV2Remote : NSObject

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone;

- (void)fetchSummaryStatsForTodayWithCompletionHandler:(StatsRemoteSummaryCompletion)completionHandler
                                        failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchVisitsStatsForPeriodUnit:(StatsPeriodUnit)unit
                withCompletionHandler:(StatsRemoteVisitsCompletion)completionHandler
                       failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchPostsStatsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
         withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchReferrersStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                    failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchClicksStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                 failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchCountryStatsForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                  failureHandler:(void (^)(NSError *error))failureHandler;
@end

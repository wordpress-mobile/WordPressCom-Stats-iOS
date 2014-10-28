#import "WPStatsService.h"
#import "StatsSummary.h"

@interface WPStatsServiceV2Remote : NSObject

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone;

- (void)fetchStatsForTodayDate:(NSDate *)today andYesterdayDate:(NSDate *)yesterday withCompletionHandler:(StatsCompletion)completionHandler failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchSummaryStatsForTodayWithCompletionHandler:(void (^)(StatsSummary *summary))completionHandler failureHandler:(void (^)(NSError *error))failureHandler;

@end

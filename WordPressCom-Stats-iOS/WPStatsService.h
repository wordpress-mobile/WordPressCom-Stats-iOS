#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"
#import "StatsGroup.h"

typedef void (^StatsSummaryCompletion)(StatsSummary *summary);
typedef void (^StatsVisitsCompletion)(StatsVisits *visits, NSError *error);
typedef void (^StatsItemsCompletion)(StatsGroup *group, NSError *error);

@class WPStatsServiceRemote;

@interface WPStatsService : NSObject

@property (nonatomic, strong) WPStatsServiceRemote *remote;

- (instancetype)initWithSiteId:(NSNumber *)siteId siteTimeZone:(NSTimeZone *)timeZone oauth2Token:(NSString *)oauth2Token andCacheExpirationInterval:(NSTimeInterval)cacheExpirationInterval;

- (void)retrieveAllStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
    withVisitsCompletionHandler:(StatsVisitsCompletion)visitsCompletion
        eventsCompletionHandler:(StatsItemsCompletion)eventsCompletion
         postsCompletionHandler:(StatsItemsCompletion)postsCompletion
     referrersCompletionHandler:(StatsItemsCompletion)referrersCompletion
        clicksCompletionHandler:(StatsItemsCompletion)clicksCompletion
       countryCompletionHandler:(StatsItemsCompletion)countryCompletion
        videosCompletionHandler:(StatsItemsCompletion)videosCompletion
commentsAuthorCompletionHandler:(StatsItemsCompletion)commentsAuthorsCompletion
 commentsPostsCompletionHandler:(StatsItemsCompletion)commentsPostsCompletion
tagsCategoriesCompletionHandler:(StatsItemsCompletion)tagsCategoriesCompletion
followersDotComCompletionHandler:(StatsItemsCompletion)followersDotComCompletion
 followersEmailCompletionHandler:(StatsItemsCompletion)followersEmailCompletion
      publicizeCompletionHandler:(StatsItemsCompletion)publicizeCompletion
     andOverallCompletionHandler:(void (^)())completionHandler;

- (void)retrieveTodayStatsWithCompletionHandler:(StatsSummaryCompletion)completion failureHandler:(void (^)(NSError *))failureHandler;

- (void)expireAllItemsInCache;

@end

#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"
#import "StatsGroup.h"

typedef void (^StatsSummaryCompletion)(StatsSummary *summary, NSError *error);
typedef void (^StatsVisitsCompletion)(StatsVisits *visits, NSError *error);
typedef void (^StatsItemsCompletion)(StatsGroup *group, NSError *error);

@class WPStatsServiceRemote;

@interface WPStatsService : NSObject

@property (nonatomic, strong) WPStatsServiceRemote *remote;

- (instancetype)initWithSiteId:(NSNumber *)siteId siteTimeZone:(NSTimeZone *)timeZone andOAuth2Token:(NSString *)oauth2Token;

- (void)retrieveAllStatsForDates:(NSArray *)dates
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

- (void)retrieveTodayStatsWithCompletionHandler:(void (^)(StatsSummaryCompletion *))completion failureHandler:(void (^)(NSError *))failureHandler;

@end

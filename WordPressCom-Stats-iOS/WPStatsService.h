#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"
#import "StatsGroup.h"

typedef void (^StatsSummaryCompletion)(StatsSummary *summary);
typedef void (^StatsVisitsCompletion)(StatsVisits *visits);
typedef void (^StatsItemsCompletion)(StatsGroup *group);

@class WPStatsServiceRemote;

@interface WPStatsService : NSObject

@property (nonatomic, strong) WPStatsServiceRemote *remote;

- (instancetype)initWithSiteId:(NSNumber *)siteId siteTimeZone:(NSTimeZone *)timeZone andOAuth2Token:(NSString *)oauth2Token;

- (void)retrieveAllStatsForDates:(NSArray *)dates
                         andUnit:(StatsPeriodUnit)unit
     withVisitsCompletionHandler:(StatsVisitsCompletion)visitsCompletion
          postsCompletionHandler:(StatsItemsCompletion)postsCompletion
      referrersCompletionHandler:(StatsItemsCompletion)referrersCompletion
         clicksCompletionHandler:(StatsItemsCompletion)clicksCompletion
        countryCompletionHandler:(StatsItemsCompletion)countryCompletion
          videosCompetionHandler:(StatsItemsCompletion)videosCompletion
              commentsCompletion:(StatsItemsCompletion)commentsCompletion
        tagsCategoriesCompletion:(StatsItemsCompletion)tagsCategoriesCompletion
             followersCompletion:(StatsItemsCompletion)followersCompletion
             publicizeCompletion:(StatsItemsCompletion)publicizeCompletion
     andOverallCompletionHandler:(void (^)())completionHandler
           overallFailureHandler:(void (^)(NSError *error))failureHandler;

- (void)retrieveTodayStatsWithCompletionHandler:(void (^)(StatsSummaryCompletion *))completion failureHandler:(void (^)(NSError *))failureHandler;

@end

#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"
#import "StatsGroup.h"
#import "StatsAllTime.h"
#import "StatsInsights.h"

typedef void (^StatsSummaryCompletion)(StatsSummary *summary, NSError *error);
typedef void (^StatsVisitsCompletion)(StatsVisits *visits, NSError *error);
typedef void (^StatsGroupCompletion)(StatsGroup *group, NSError *error);
typedef void (^StatsPostDetailsCompletion)(StatsVisits *visits, StatsGroup *monthsYears, StatsGroup *averagePerDay, StatsGroup *recentWeeks, NSError *error);
typedef void (^StatsInsightsCompletion)(StatsInsights *insights, NSError *error);
typedef void (^StatsAllTimeCompletion)(StatsAllTime *allTime, NSError *error);

typedef NS_ENUM(NSUInteger, StatsFollowerType) {
    StatsFollowerTypeDotCom,
    StatsFollowerTypeEmail
};

@class WPStatsServiceRemote;

@interface WPStatsService : NSObject

@property (nonatomic, strong) WPStatsServiceRemote *remote;
@property (nonatomic, readonly) NSNumber *siteId;
@property (nonatomic, readonly) NSTimeZone *siteTimeZone;

- (instancetype)initWithSiteId:(NSNumber *)siteId siteTimeZone:(NSTimeZone *)timeZone oauth2Token:(NSString *)oauth2Token andCacheExpirationInterval:(NSTimeInterval)cacheExpirationInterval;

- (void)retrieveAllStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
    withVisitsCompletionHandler:(StatsVisitsCompletion)visitsCompletion
        eventsCompletionHandler:(StatsGroupCompletion)eventsCompletion
         postsCompletionHandler:(StatsGroupCompletion)postsCompletion
     referrersCompletionHandler:(StatsGroupCompletion)referrersCompletion
        clicksCompletionHandler:(StatsGroupCompletion)clicksCompletion
       countryCompletionHandler:(StatsGroupCompletion)countryCompletion
        videosCompletionHandler:(StatsGroupCompletion)videosCompletion
       authorsCompletionHandler:(StatsGroupCompletion)authorsCompletion
   searchTermsCompletionHandler:(StatsGroupCompletion)searchTermsCompletionHandler
commentsAuthorCompletionHandler:(StatsGroupCompletion)commentsAuthorsCompletion
 commentsPostsCompletionHandler:(StatsGroupCompletion)commentsPostsCompletion
tagsCategoriesCompletionHandler:(StatsGroupCompletion)tagsCategoriesCompletion
followersDotComCompletionHandler:(StatsGroupCompletion)followersDotComCompletion
 followersEmailCompletionHandler:(StatsGroupCompletion)followersEmailCompletion
     publicizeCompletionHandler:(StatsGroupCompletion)publicizeCompletion
                  progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)) progressBlock
     andOverallCompletionHandler:(void (^)(BOOL cachedDataWasUsed))completionHandler;

- (void)retrievePostDetailsStatsForPostID:(NSNumber *)postID
                    withCompletionHandler:(StatsPostDetailsCompletion)completion;

- (void)retrievePostsForDate:(NSDate *)date
                     andUnit:(StatsPeriodUnit)unit
       withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveReferrersForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveClicksForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveCountriesForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveVideosForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveAuthorsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
         withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveSearchTermsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveFollowersOfType:(StatsFollowerType)followersType
                        forDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsGroupCompletion)completionHandler;

- (void)retrieveInsightsStatsWithAllTimeStatsCompletionHandler:(StatsAllTimeCompletion)allTimeCompletion
                                     insightsCompletionHandler:(StatsInsightsCompletion)insightsCompletion
                                 todaySummaryCompletionHandler:(StatsSummaryCompletion)todaySummaryCompletion
                                                 progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)) progressBlock
                                   andOverallCompletionHandler:(void (^)(BOOL cachedDataWasUsed))completionHandler;

- (void)retrieveTodayStatsWithCompletionHandler:(StatsSummaryCompletion)completion failureHandler:(void (^)(NSError *))failureHandler;

- (void)cancelAnyRunningOperations;
- (void)expireAllItemsInCache;

@end

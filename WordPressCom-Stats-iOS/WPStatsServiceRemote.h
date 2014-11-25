#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"

typedef void (^StatsRemoteSummaryCompletion)(StatsSummary *summary);
typedef void (^StatsRemoteVisitsCompletion)(StatsVisits *visits);
typedef void (^StatsRemoteItemsCompletion)(NSArray *items, NSNumber *totalViews, NSNumber *otherViews);

@interface WPStatsServiceRemote : NSObject

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone;

/**
 Batches all remote calls locally to retrieve stats for a particular set of dates and period.  Completion handlers are called
 
 @param dates An array with at least one date.  Completion handlers may be called more than once if multiple dates are given.
 @param unit Period unit to run stats for
 @param summaryCompletion
 @param visitsCompletion
 @param postsCompletion
 @param referrersCompletion
 @param clicksCompletion
 @param countryCompletion
 @param failureHandler
 
 */
- (void)batchFetchStatsForDates:(NSArray *)dates
                        andUnit:(StatsPeriodUnit)unit
   withSummaryCompletionHandler:(StatsRemoteSummaryCompletion)summaryCompletion
        visitsCompletionHandler:(StatsRemoteVisitsCompletion)visitsCompletion
         postsCompletionHandler:(StatsRemoteItemsCompletion)postsCompletion
     referrersCompletionHandler:(StatsRemoteItemsCompletion)referrersCompletion
        clicksCompletionHandler:(StatsRemoteItemsCompletion)clicksCompletion
       countryCompletionHandler:(StatsRemoteItemsCompletion)countryCompletion
         videosCompetionHandler:(StatsRemoteItemsCompletion)videosCompletion
             commentsCompletion:(StatsRemoteItemsCompletion)commentsCompletion
       tagsCategoriesCompletion:(StatsRemoteItemsCompletion)tagsCategoriesCompletion
            followersCompletion:(StatsRemoteItemsCompletion)followersCompletion
            publicizeCompletion:(StatsRemoteItemsCompletion)publicizeCompletion
    andOverallCompletionHandler:(void (^)())completionHandler
          overallFailureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchSummaryStatsForDate:(NSDate *)date
           withCompletionHandler:(StatsRemoteSummaryCompletion)completionHandler
                  failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchVisitsStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
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

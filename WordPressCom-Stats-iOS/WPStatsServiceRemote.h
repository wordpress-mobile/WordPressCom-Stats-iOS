#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"
#import "WPStatsService.h"

typedef void (^StatsRemoteSummaryCompletion)(StatsSummary *summary, NSError *error);
typedef void (^StatsRemoteVisitsCompletion)(StatsVisits *visits, NSError *error);
typedef void (^StatsRemoteItemsCompletion)(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error);
typedef void (^StatsRemotePostDetailsCompletion)(StatsVisits *visits, NSArray *monthsYearsItems, NSArray *averagePerDayItems, NSArray *recentWeeksItems, NSError *error);

@interface WPStatsServiceRemote : NSObject

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone;

/**
 Batches all remote calls locally to retrieve stats for a particular set of dates and period.  Completion handlers are called
 
 @param date End date of period to fetch stats for
 @param unit Period unit to run stats for
 @param summaryCompletion
 @param visitsCompletion
 @param postsCompletion
 @param referrersCompletion
 @param clicksCompletion
 @param countryCompletion
 @param videosCompletion
 @param commentsCompletion items is an array of arrays = position 0 = authors, position 1 = posts (hacky)
 @param tagsCategoriesCompletion
 @param followersDotComCompletion
 @param followersEmailCompletion
 @param publicizeCompletion
 @param failureHandler
 
 */
- (void)batchFetchStatsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
   withVisitsCompletionHandler:(StatsRemoteVisitsCompletion)visitsCompletion
       eventsCompletionHandler:(StatsRemoteItemsCompletion)eventsCompletion
        postsCompletionHandler:(StatsRemoteItemsCompletion)postsCompletion
    referrersCompletionHandler:(StatsRemoteItemsCompletion)referrersCompletion
       clicksCompletionHandler:(StatsRemoteItemsCompletion)clicksCompletion
      countryCompletionHandler:(StatsRemoteItemsCompletion)countryCompletion
       videosCompletionHandler:(StatsRemoteItemsCompletion)videosCompletion
      authorsCompletionHandler:(StatsRemoteItemsCompletion)authorsCompletion
  searchTermsCompletionHandler:(StatsRemoteItemsCompletion)searchTermsCompletion
     commentsCompletionHandler:(StatsRemoteItemsCompletion)commentsCompletion
tagsCategoriesCompletionHandler:(StatsRemoteItemsCompletion)tagsCategoriesCompletion
followersDotComCompletionHandler:(StatsRemoteItemsCompletion)followersDotComCompletion
followersEmailCompletionHandler:(StatsRemoteItemsCompletion)followersEmailCompletion
     publicizeCompletionHandler:(StatsRemoteItemsCompletion)publicizeCompletion
    andOverallCompletionHandler:(void (^)())completionHandler;

- (void)fetchPostDetailsStatsForPostID:(NSNumber *)postID
                 withCompletionHandler:(StatsRemotePostDetailsCompletion)completionHandler;

- (void)fetchSummaryStatsForDate:(NSDate *)date
           withCompletionHandler:(StatsRemoteSummaryCompletion)completionHandler;

- (void)fetchEventsForDate:(NSDate *)date
                   andUnit:(StatsPeriodUnit)unit
     withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchVisitsStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteVisitsCompletion)completionHandler;

- (void)fetchPostsStatsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
         withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchReferrersStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchClicksStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchCountryStatsForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchVideosStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchAuthorsStatsForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchSearchTermsStatsForDate:(NSDate *)date
                             andUnit:(StatsPeriodUnit)unit
               withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchCommentsStatsForDate:(NSDate *)date
                          andUnit:(StatsPeriodUnit)unit
            withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchTagsCategoriesStatsForDate:(NSDate *)date
                                andUnit:(StatsPeriodUnit)unit
                  withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchFollowersStatsForFollowerType:(StatsFollowerType)followerType
                                      date:(NSDate *)date
                                   andUnit:(StatsPeriodUnit)unit
                     withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)fetchPublicizeStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler;

- (void)cancelAllRemoteOperations;

@end

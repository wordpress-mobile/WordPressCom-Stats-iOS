#import <Foundation/Foundation.h>
#import "StatsSummary.h"
#import "StatsVisits.h"

typedef void (^StatsRemoteSummaryCompletion)(StatsSummary *summary);
typedef void (^StatsRemoteVisitsCompletion)(StatsVisits *visits);
typedef void (^StatsRemoteItemsCompletion)(NSArray *items, NSString *totalViews, NSString *otherViews);

typedef NS_ENUM(NSUInteger, StatsFollowerType) {
    StatsFollowerTypeDotCom,
    StatsFollowerTypeEmail
};


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
    withVisitsCompletionHandler:(StatsRemoteVisitsCompletion)visitsCompletion
         postsCompletionHandler:(StatsRemoteItemsCompletion)postsCompletion
     referrersCompletionHandler:(StatsRemoteItemsCompletion)referrersCompletion
        clicksCompletionHandler:(StatsRemoteItemsCompletion)clicksCompletion
       countryCompletionHandler:(StatsRemoteItemsCompletion)countryCompletion
        videosCompletionHandler:(StatsRemoteItemsCompletion)videosCompletion
      commentsCompletionHandler:(StatsRemoteItemsCompletion)commentsCompletion
tagsCategoriesCompletionHandler:(StatsRemoteItemsCompletion)tagsCategoriesCompletion
followersDotComCompletionHandler:(StatsRemoteItemsCompletion)followersDotComCompletion
followersEmailCompletionHandler:(StatsRemoteItemsCompletion)followersEmailCompletion
     publicizeCompletionHandler:(StatsRemoteItemsCompletion)publicizeCompletion
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

- (void)fetchVideosStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                 failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchCommentsStatsForDate:(NSDate *)date
                          andUnit:(StatsPeriodUnit)unit
            withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                   failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchTagsCategoriesStatsForDate:(NSDate *)date
                                andUnit:(StatsPeriodUnit)unit
                  withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                         failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchFollowersStatsForFollowerType:(StatsFollowerType)followerType
                                      date:(NSDate *)date
                                   andUnit:(StatsPeriodUnit)unit
                     withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                            failureHandler:(void (^)(NSError *error))failureHandler;

- (void)fetchPublicizeStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                    failureHandler:(void (^)(NSError *error))failureHandler;
@end

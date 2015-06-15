#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsGroup.h"
#import "StatsVisits.h"
#import "StatsSummary.h"
#import "StatsEphemory.h"
#import "StatsDateUtilities.h"
#import "StatsSection.h"

@interface WPStatsService ()

@property (nonatomic, strong) NSNumber *siteId;
@property (nonatomic, strong) NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;
@property (nonatomic, strong) StatsEphemory *ephemory;
@property (nonatomic, strong) StatsDateUtilities *dateUtilities;

@end

@implementation WPStatsService
{

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSTimeInterval fiveMinutes = 60.0 * 5.0;
        _ephemory = [[StatsEphemory alloc] initWithExpiryInterval:fiveMinutes];
    }
    return self;
}

- (instancetype)initWithSiteId:(NSNumber *)siteId siteTimeZone:(NSTimeZone *)timeZone oauth2Token:(NSString *)oauth2Token andCacheExpirationInterval:(NSTimeInterval)cacheExpirationInterval
{
    NSAssert(oauth2Token.length > 0, @"OAuth2 token must not be empty.");
    NSAssert(siteId != nil, @"Site ID must not be nil.");
    NSAssert(timeZone != nil, @"Timezone must not be nil.");

    self = [super init];
    if (self) {
        _siteId = siteId;
        _oauth2Token = oauth2Token;
        _siteTimeZone = timeZone ?: [NSTimeZone localTimeZone];
        _ephemory = [[StatsEphemory alloc] initWithExpiryInterval:cacheExpirationInterval];
    }

    return self;
}

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
   searchTermsCompletionHandler:(StatsGroupCompletion)searchTermsCompletion
commentsAuthorCompletionHandler:(StatsGroupCompletion)commentsAuthorsCompletion
 commentsPostsCompletionHandler:(StatsGroupCompletion)commentsPostsCompletion
tagsCategoriesCompletionHandler:(StatsGroupCompletion)tagsCategoriesCompletion
followersDotComCompletionHandler:(StatsGroupCompletion)followersDotComCompletion
 followersEmailCompletionHandler:(StatsGroupCompletion)followersEmailCompletion
      publicizeCompletionHandler:(StatsGroupCompletion)publicizeCompletion
                  progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)) progressBlock
     andOverallCompletionHandler:(void (^)(BOOL cachedDataWasUsed))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    NSMutableDictionary *cacheDictionary = [self.ephemory objectForKey:@[@"BatchStats", @(unit), endDate]];
    id visitsData = cacheDictionary[@(StatsSectionGraph)];
    id eventsData = cacheDictionary[@(StatsSectionEvents)];
    id postsData = cacheDictionary[@(StatsSectionPosts)];
    id referrersData = cacheDictionary[@(StatsSectionReferrers)];
    id clicksData = cacheDictionary[@(StatsSectionClicks)];
    id countryData = cacheDictionary[@(StatsSectionCountry)];
    id videosData = cacheDictionary[@(StatsSectionVideos)];
    id authorsData = cacheDictionary[@(StatsSectionAuthors)];
    id searchTermsData = cacheDictionary[@(StatsSectionSearchTerms)];
    id commentsAuthorData = cacheDictionary[@(StatsSubSectionCommentsByAuthor)];
    id commentsPostsData = cacheDictionary[@(StatsSubSectionCommentsByPosts)];
    id tagsCategoriesData = cacheDictionary[@(StatsSectionTagsCategories)];
    id followersDotComData = cacheDictionary[@(StatsSubSectionFollowersDotCom)];
    id followersEmailData = cacheDictionary[@(StatsSubSectionFollowersEmail)];
    id publicizeData = cacheDictionary[@(StatsSectionPublicize)];
    
    if (cacheDictionary
        && (!visitsCompletion || visitsData)
        && (!eventsCompletion || eventsData)
        && (!postsCompletion || postsData)
        && (!referrersCompletion || referrersData)
        && (!clicksCompletion || clicksData)
        && (!countryCompletion || countryData)
        && (!videosCompletion || videosData)
        && (!authorsCompletion || authorsData)
        && (!searchTermsCompletion || searchTermsData)
        && (!commentsAuthorsCompletion || commentsAuthorData)
        && (!commentsPostsCompletion || commentsPostsData)
        && (!tagsCategoriesCompletion || tagsCategoriesData)
        && (!followersDotComCompletion || followersDotComData)
        && (!followersEmailCompletion || followersEmailData)
        && (!publicizeCompletion || publicizeData)
    ) {
        DDLogVerbose(@"retrieveAllStatsForDate - Cached data exists.");
        if (visitsCompletion) {
            visitsCompletion(visitsData, nil);
        }

        if (eventsCompletion) {
            eventsCompletion(eventsData, nil);
        }

        if (postsCompletion) {
            postsCompletion(postsData, nil);
        }
    
        if (referrersCompletion) {
            referrersCompletion(referrersData, nil);
        }
    
        if (clicksCompletion) {
            clicksCompletion(clicksData, nil);
        }
    
        if (countryCompletion) {
            countryCompletion(countryData, nil);
        }
    
        if (videosCompletion) {
            videosCompletion(videosData, nil);
        }
    
        if (authorsCompletion) {
            authorsCompletion(authorsData, nil);
        }
        
        if (searchTermsCompletion) {
            searchTermsCompletion(searchTermsData, nil);
        }
        
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(commentsAuthorData, nil);
        }
        
        if (commentsPostsCompletion) {
            commentsPostsCompletion(commentsPostsData, nil);
        }
    
        if (tagsCategoriesCompletion) {
            tagsCategoriesCompletion(tagsCategoriesData, nil);
        }
    
        if (followersDotComCompletion) {
            followersDotComCompletion(followersDotComData, nil);
        }
    
        if (followersEmailCompletion) {
            followersEmailCompletion(followersEmailData, nil);
        }
    
        if (publicizeCompletion) {
            publicizeCompletion(publicizeData, nil);
        }
        
        completionHandler(YES);
        
        return;
    } else {
        cacheDictionary = [NSMutableDictionary new];
        [self.ephemory setObject:cacheDictionary forKey:@[@"BatchStats", @(unit), endDate]];
    }

    [self.remote cancelAllRemoteOperations];
    [self.remote batchFetchStatsForDate:endDate
                                andUnit:unit
            withVisitsCompletionHandler:[self remoteVisitsCompletionWithCache:cacheDictionary andCompletionHandler:visitsCompletion]
                eventsCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionEvents andCompletionHandler:eventsCompletion]
                 postsCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionPosts andCompletionHandler:postsCompletion]
             referrersCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionReferrers andCompletionHandler:referrersCompletion]
                clicksCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionClicks andCompletionHandler:clicksCompletion]
               countryCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionCountry andCompletionHandler:countryCompletion]
                videosCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionVideos andCompletionHandler:videosCompletion]
               authorsCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionAuthors andCompletionHandler:authorsCompletion]
           searchTermsCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionSearchTerms andCompletionHandler:searchTermsCompletion]
              commentsCompletionHandler:[self remoteCommentsCompletionWithCache:cacheDictionary andCommentsAuthorsCompletion:commentsAuthorsCompletion commentsPostsCompletion:commentsPostsCompletion]
        tagsCategoriesCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionTagsCategories andCompletionHandler:tagsCategoriesCompletion]
       followersDotComCompletionHandler:[self remoteFollowersCompletionWithCache:cacheDictionary followerType:StatsFollowerTypeDotCom andCompletionHandler:followersDotComCompletion]
        followersEmailCompletionHandler:[self remoteFollowersCompletionWithCache:cacheDictionary followerType:StatsFollowerTypeEmail andCompletionHandler:followersEmailCompletion]
             publicizeCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionPublicize andCompletionHandler:publicizeCompletion]
                          progressBlock:progressBlock
            andOverallCompletionHandler:^
    {
        completionHandler(NO);
    }];
}


- (void)retrieveInsightsStatsWithAllTimeStatsCompletionHandler:(StatsAllTimeCompletion)allTimeCompletion
                                     insightsCompletionHandler:(StatsInsightsCompletion)insightsCompletion
                                 todaySummaryCompletionHandler:(StatsSummaryCompletion)todaySummaryCompletion
                                                 progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)) progressBlock
                                   andOverallCompletionHandler:(void (^)(BOOL cachedDataWasUsed))overallCompletionHandler
{
    NSString *cacheKey = @"BatchInsights";
    NSString *allTimeCacheKey = @"AllTime";
    NSString *insightsCacheKey = @"Insights";
    NSString *todayCacheKey = @"Today";
    
    NSMutableDictionary *cacheDictionary = [self.ephemory objectForKey:cacheKey];
    if (cacheDictionary.count == 3) {
        DDLogVerbose(@"retrieveInsightsStats - Cached data exists.");
        if (allTimeCompletion) {
            allTimeCompletion(cacheDictionary[allTimeCacheKey], nil);
        }
        if (insightsCompletion) {
            insightsCompletion(cacheDictionary[insightsCacheKey], nil);
        }
        if (todaySummaryCompletion) {
            todaySummaryCompletion(cacheDictionary[todayCacheKey], nil);
        }
        
        if (overallCompletionHandler) {
            overallCompletionHandler(YES);
        }
        
        return;
    }

    [self.remote batchFetchInsightsStatsWithAllTimeCompletionHandler:^(NSString *posts, NSNumber *postsValue, NSString *views, NSNumber *viewsValue, NSString *visitors, NSNumber *visitorsValue, NSString *bestViews, NSNumber *bestViewsValue, NSString *bestViewsOn, NSError *error)
    {
        StatsAllTime *allTime = [StatsAllTime new];
        allTime.numberOfPosts = posts;
        allTime.numberOfPostsValue = postsValue;
        allTime.numberOfViews = views;
        allTime.numberOfViewsValue = viewsValue;
        allTime.numberOfVisitors = visitors;
        allTime.numberOfVisitorsValue = visitorsValue;
        allTime.bestNumberOfViews = bestViews;
        allTime.bestNumberOfViewsValue = bestViewsValue;
        allTime.bestViewsOn = bestViewsOn;
        
        cacheDictionary[allTimeCacheKey] = allTime;
        
        if (allTimeCompletion) {
            allTimeCompletion(allTime, error);
        }
    }
                                           insightsCompletionHandler:^(NSString *highestHour, NSString *highestHourPercent, NSNumber *highestHourPercentValue,NSString *highestDayOfWeek, NSString *highestDayPercent, NSNumber *highestDayPercentValue, NSError *error)
    {
        StatsInsights *insights = [StatsInsights new];
        insights.highestHour = highestHour;
        insights.highestHourPercent = highestHourPercent;
        insights.highestHourPercentValue = highestHourPercentValue;
        insights.highestDayOfWeek = highestDayOfWeek;
        insights.highestDayPercent = highestDayPercent;
        insights.highestDayPercentValue = highestDayPercentValue;
        
        cacheDictionary[insightsCacheKey] = insights;
        
        if (insightsCompletion) {
            insightsCompletion(insights, error);
        }
    }
                                       todaySummaryCompletionHandler:^(StatsSummary *summary, NSError *error)
    {
        cacheDictionary[todayCacheKey] = summary;
        
        if (todaySummaryCompletion) {
            todaySummaryCompletion(summary, error);
        }
    }
                                                       progressBlock:progressBlock
                                         andOverallCompletionHandler:^
    {
        if (overallCompletionHandler) {
            overallCompletionHandler(NO);
        }
    }];
}


- (void)retrievePostDetailsStatsForPostID:(NSNumber *)postID
                    withCompletionHandler:(StatsPostDetailsCompletion)completion
{
    if (!postID || !completion) {
        return;
    }
    
    [self.remote fetchPostDetailsStatsForPostID:postID withCompletionHandler:^(StatsVisits *visits, NSArray *monthsYearsItems, NSArray *averagePerDayItems, NSArray *recentWeeksItems, NSError *error) {
        StatsGroup *monthsYears = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsMonthsYears andStatsSubSection:StatsSubSectionNone];
        monthsYears.items = monthsYearsItems;
        monthsYears.errorWhileRetrieving = !error;
        
        StatsGroup *averagePerDay = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsAveragePerDay andStatsSubSection:StatsSubSectionNone];
        averagePerDay.items = averagePerDayItems;
        averagePerDay.errorWhileRetrieving = !error;
        
        StatsGroup *recentWeeks = [[StatsGroup alloc] initWithStatsSection:StatsSectionPostDetailsRecentWeeks andStatsSubSection:StatsSubSectionNone];
        recentWeeks.items = recentWeeksItems;
        recentWeeks.errorWhileRetrieving = !error;
        
        completion(visits, monthsYears, averagePerDay, recentWeeks, error);
    }];
    
}


- (void)retrievePostsForDate:(NSDate *)date
                     andUnit:(StatsPeriodUnit)unit
       withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];

    [self.remote fetchPostsStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionPosts andCompletionHandler:completionHandler]];
}


- (void)retrieveReferrersForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];

    [self.remote fetchReferrersStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionReferrers andCompletionHandler:completionHandler]];
}


- (void)retrieveClicksForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    
    [self.remote fetchClicksStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil  forStatsSection:StatsSectionClicks andCompletionHandler:completionHandler]];
}


- (void)retrieveCountriesForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    
    [self.remote fetchCountryStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil  forStatsSection:StatsSectionCountry andCompletionHandler:completionHandler]];
}


- (void)retrieveVideosForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    
    [self.remote fetchVideosStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionVideos andCompletionHandler:completionHandler]];
}


- (void)retrieveFollowersOfType:(StatsFollowerType)followersType
                        forDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    
    [self.remote fetchFollowersStatsForFollowerType:followersType date:endDate andUnit:unit withCompletionHandler:[self remoteFollowersCompletionWithCache:nil followerType:followersType andCompletionHandler:completionHandler]];
}



- (void)retrieveAuthorsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
         withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    
    [self.remote fetchAuthorsStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionAuthors andCompletionHandler:completionHandler]];
}


- (void)retrieveSearchTermsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    
    [self.remote fetchSearchTermsStatsForDate:endDate andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionSearchTerms andCompletionHandler:completionHandler]];
}


- (void)retrieveTodayStatsWithCompletionHandler:(StatsSummaryCompletion)completion failureHandler:(void (^)(NSError *))failureHandler
{
    void (^failure)(NSError *error) = ^void (NSError *error) {
        DDLogError(@"Error while retrieving stats: %@", error);
        
        if (failureHandler) {
            failureHandler(error);
        }
    };
    
    if (!completion) {
        return;
    }
    
    StatsSummary *summary = [self.ephemory objectForKey:@"TodayStats"];
    if (summary) {
        completion(summary, nil);
    }
    
    [self.remote fetchSummaryStatsForDate:[NSDate date]
                    withCompletionHandler:^(StatsSummary *statsSummary, NSError *error) {
                        if (error) {
                            failure(error);
                            return;
                        }

                        [self.ephemory setObject:statsSummary forKey:@"TodayStats"];

                        completion(statsSummary, nil);
                    }];
}


- (WPStatsServiceRemote *)remote
{
    if (!_remote) {
        _remote = [[WPStatsServiceRemote alloc] initWithOAuth2Token:self.oauth2Token siteId:self.siteId andSiteTimeZone:self.siteTimeZone];
    }

    return _remote;
}


- (void)expireAllItemsInCache
{
    [self.ephemory removeAllObjects];
}


- (void)cancelAnyRunningOperations
{
    [self.remote cancelAllRemoteOperations];
}

#pragma mark - Private completion handler helpers

- (StatsRemoteVisitsCompletion)remoteVisitsCompletionWithCache:(NSMutableDictionary *)cacheDictionary andCompletionHandler:(StatsVisitsCompletion)visitsCompletion
{
    return ^(StatsVisits *visits, NSError *error)
    {
        cacheDictionary[@(StatsSectionGraph)] = visits;
        
        if (error) {
            DDLogError(@"Error while fetching Visits: %@", error);
            visits.errorWhileRetrieving = YES;
        }
        
        if (visitsCompletion) {
            visitsCompletion(visits, error);
        }
    };
}


- (StatsRemoteItemsCompletion)remoteItemCompletionWithCache:(NSMutableDictionary *)cacheDictionary forStatsSection:(StatsSection)statsSection andCompletionHandler:(StatsGroupCompletion)groupCompletion
{
    return ^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *groupResult = [[StatsGroup alloc] initWithStatsSection:statsSection andStatsSubSection:StatsSubSectionNone];
        groupResult.items = items;
        groupResult.moreItemsExist = moreViewsAvailable;
        groupResult.errorWhileRetrieving = error != nil;
        
        cacheDictionary[@(statsSection)] = groupResult;
        
        if (groupCompletion) {
            groupCompletion(groupResult, error);
        }
    };
}


- (StatsRemoteItemsCompletion)remoteCommentsCompletionWithCache:(NSMutableDictionary *)cacheDictionary
                                    andCommentsAuthorsCompletion:(StatsGroupCompletion)commentsAuthorsCompletion
                                        commentsPostsCompletion:(StatsGroupCompletion)commentsPostsCompletion
{
    return ^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *commentsAuthorsResult = [[StatsGroup alloc] initWithStatsSection:StatsSectionComments andStatsSubSection:StatsSubSectionCommentsByAuthor];
        commentsAuthorsResult.items = items.firstObject;
        commentsAuthorsResult.errorWhileRetrieving = error != nil;
        
        StatsGroup *commentsPostsResult = [[StatsGroup alloc] initWithStatsSection:StatsSectionComments andStatsSubSection:StatsSubSectionCommentsByPosts];
        commentsPostsResult.items = items.lastObject;
        commentsPostsResult.errorWhileRetrieving = error != nil;
        
        cacheDictionary[@(StatsSubSectionCommentsByAuthor)] = commentsAuthorsResult;
        cacheDictionary[@(StatsSubSectionCommentsByPosts)] = commentsPostsResult;
        
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(commentsAuthorsResult, error);
        }
        
        if (commentsPostsCompletion) {
            commentsPostsCompletion(commentsPostsResult, error);
        }
    };
}


- (StatsRemoteItemsCompletion)remoteFollowersCompletionWithCache:(NSMutableDictionary *)cacheDictionary followerType:(StatsFollowerType)followerType andCompletionHandler:(StatsGroupCompletion)groupCompletion
{
    return ^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsSubSection statsSubSection = followerType == StatsFollowerTypeDotCom ? StatsSubSectionFollowersDotCom : StatsSubSectionFollowersEmail;
        StatsGroup *followersResult = [[StatsGroup alloc] initWithStatsSection:StatsSectionFollowers andStatsSubSection:statsSubSection];
        followersResult.items = items;
        followersResult.moreItemsExist = moreViewsAvailable;
        followersResult.totalCount = totalViews;
        followersResult.errorWhileRetrieving = error != nil;
        
        cacheDictionary[@(statsSubSection)] = followersResult;
        
        for (StatsItem *item in items) {
            NSString *age = [self.dateUtilities dateAgeForDate:item.date];
            item.value = age;
        }
        
        if (groupCompletion) {
            groupCompletion(followersResult, error);
        }
    };
}


#pragma mark - Private helper methods


- (StatsDateUtilities *)dateUtilities
{
    if (!_dateUtilities) {
        _dateUtilities = [StatsDateUtilities new];
    }
    
    return _dateUtilities;
}


@end

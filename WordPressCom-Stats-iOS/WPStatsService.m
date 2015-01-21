#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsGroup.h"
#import "StatsVisits.h"
#import "StatsSummary.h"
#import "StatsEphemory.h"
#import "StatsDateUtilities.h"

typedef NS_ENUM(NSInteger, StatsCache) {
    StatsCacheNone,
    StatsCacheVisits,
    StatsCacheEvents,
    StatsCachePosts,
    StatsCacheReferrers,
    StatsCacheClicks,
    StatsCacheCountry,
    StatsCacheVideos,
    StatsCacheCommentsAuthors,
    StatsCacheCommentsPosts,
    StatsCacheTagsCategories,
    StatsCacheFollowersDotCom,
    StatsCacheFollowersEmail,
    StatsCachePublicize
};

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
        _siteTimeZone = timeZone ?: [NSTimeZone systemTimeZone];
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
commentsAuthorCompletionHandler:(StatsGroupCompletion)commentsAuthorsCompletion
 commentsPostsCompletionHandler:(StatsGroupCompletion)commentsPostsCompletion
tagsCategoriesCompletionHandler:(StatsGroupCompletion)tagsCategoriesCompletion
followersDotComCompletionHandler:(StatsGroupCompletion)followersDotComCompletion
 followersEmailCompletionHandler:(StatsGroupCompletion)followersEmailCompletion
      publicizeCompletionHandler:(StatsGroupCompletion)publicizeCompletion
     andOverallCompletionHandler:(void (^)())completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    NSDate *endDate = [self.dateUtilities calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    NSMutableDictionary *cacheDictionary = [self.ephemory objectForKey:@[@(unit), endDate]];
    DDLogVerbose(@"Cache count: %@", @(cacheDictionary.count));
    
    if (cacheDictionary && cacheDictionary.count == 13) {
        if (visitsCompletion) {
            visitsCompletion(cacheDictionary[@(StatsCacheVisits)], nil);
        }

        if (eventsCompletion) {
            eventsCompletion(cacheDictionary[@(StatsCacheEvents)], nil);
        }

        if (postsCompletion) {
            postsCompletion(cacheDictionary[@(StatsCachePosts)], nil);
        }
    
        if (referrersCompletion) {
            referrersCompletion(cacheDictionary[@(StatsCacheReferrers)], nil);
        }
    
        if (clicksCompletion) {
            clicksCompletion(cacheDictionary[@(StatsCacheClicks)], nil);
        }
    
        if (countryCompletion) {
            countryCompletion(cacheDictionary[@(StatsCacheCountry)], nil);
        }
    
        if (videosCompletion) {
            videosCompletion(cacheDictionary[@(StatsCacheVideos)], nil);
        }
    
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(cacheDictionary[@(StatsCacheCommentsAuthors)], nil);
        }
        
        if (commentsPostsCompletion) {
            commentsPostsCompletion(cacheDictionary[@(StatsCacheCommentsPosts)], nil);
        }
    
        if (tagsCategoriesCompletion) {
            tagsCategoriesCompletion(cacheDictionary[@(StatsCacheTagsCategories)], nil);
        }
    
        if (followersDotComCompletion) {
            followersDotComCompletion(cacheDictionary[@(StatsCacheFollowersDotCom)], nil);
        }
    
        if (followersEmailCompletion) {
            followersEmailCompletion(cacheDictionary[@(StatsCacheFollowersEmail)], nil);
        }
    
        if (publicizeCompletion) {
            publicizeCompletion(cacheDictionary[@(StatsCachePublicize)], nil);
        }
        
        completionHandler();
        
        return;
    } else {
        cacheDictionary = [NSMutableDictionary new];
        [self.ephemory setObject:cacheDictionary forKey:@[@(unit), endDate]];
    }

    [self.remote cancelAllRemoteOperations];
    [self.remote batchFetchStatsForDate:endDate
                                andUnit:unit
            withVisitsCompletionHandler:[self remoteVisitsCompletionWithCache:cacheDictionary andCompletionHandler:visitsCompletion]
                eventsCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCacheEvents andCompletionHandler:eventsCompletion]
                 postsCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCachePosts andCompletionHandler:postsCompletion]
             referrersCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCacheReferrers andCompletionHandler:referrersCompletion]
                clicksCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCacheClicks andCompletionHandler:clicksCompletion]
               countryCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCacheCountry andCompletionHandler:countryCompletion]
                videosCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCacheVideos andCompletionHandler:videosCompletion]
              commentsCompletionHandler:[self remoteCommentsCompletionWithCache:cacheDictionary andCommentsAuthorsCompletion:commentsAuthorsCompletion commentsPostsCompletion:commentsPostsCompletion]
        tagsCategoriesCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCacheTagsCategories andCompletionHandler:tagsCategoriesCompletion]
       followersDotComCompletionHandler:[self remoteFollowersCompletionWithCache:cacheDictionary cacheType:StatsCacheFollowersDotCom andCompletionHandler:followersDotComCompletion]
        followersEmailCompletionHandler:[self remoteFollowersCompletionWithCache:cacheDictionary cacheType:StatsCacheFollowersEmail andCompletionHandler:followersEmailCompletion]
             publicizeCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary cacheType:StatsCachePublicize andCompletionHandler:publicizeCompletion]
            andOverallCompletionHandler:^
    {
        completionHandler();
    }];
}


- (void)retrievePostsForDate:(NSDate *)date
                     andUnit:(StatsPeriodUnit)unit
       withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchPostsStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil cacheType:StatsCacheNone andCompletionHandler:completionHandler]];
    
}


- (void)retrieveReferrersForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchReferrersStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil cacheType:StatsCacheNone andCompletionHandler:completionHandler]];
}


- (void)retrieveClicksForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchClicksStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil cacheType:StatsCacheNone andCompletionHandler:completionHandler]];
}


- (void)retrieveCountriesForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchCountryStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil cacheType:StatsCacheNone andCompletionHandler:completionHandler]];
}


- (void)retrieveVideosForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchVideosStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil cacheType:StatsCacheNone andCompletionHandler:completionHandler]];
}


- (void)retrieveFollowersOfType:(StatsFollowerType)followersType
                        forDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchFollowersStatsForFollowerType:followersType date:date andUnit:unit withCompletionHandler:[self remoteFollowersCompletionWithCache:nil cacheType:StatsCacheNone andCompletionHandler:completionHandler]];
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
        completion(summary);
    }
    
    [self.remote fetchSummaryStatsForDate:[NSDate date]
                    withCompletionHandler:^(StatsSummary *summary, NSError *error) {
                        if (error) {
                            failure(error);
                            return;
                        }

                        [self.ephemory setObject:summary forKey:@"TodayStats"];

                        completion(summary);
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


#pragma mark - Private completion handler helpers

- (StatsRemoteVisitsCompletion)remoteVisitsCompletionWithCache:(NSMutableDictionary *)cacheDictionary andCompletionHandler:(StatsVisitsCompletion)visitsCompletion
{
    return ^(StatsVisits *visits, NSError *error)
    {
        cacheDictionary[@(StatsCacheVisits)] = visits;
        visits.errorWhileRetrieving = error != nil;
        
        if (visitsCompletion) {
            visitsCompletion(visits, error);
        }
    };
}


- (StatsRemoteItemsCompletion)remoteItemCompletionWithCache:(NSMutableDictionary *)cacheDictionary cacheType:(StatsCache)cacheType andCompletionHandler:(StatsGroupCompletion)groupCompletion
{
    return ^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *groupResult = [StatsGroup new];
        groupResult.items = items;
        groupResult.moreItemsExist = moreViewsAvailable;
        groupResult.errorWhileRetrieving = error != nil;
        
        if (!cacheDictionary && cacheType != StatsCacheNone) {
            cacheDictionary[@(cacheType)] = groupResult;
        }
        
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
        StatsGroup *commentsAuthorsResult = [StatsGroup new];
        commentsAuthorsResult.items = items.firstObject;
        commentsAuthorsResult.errorWhileRetrieving = error != nil;
        
        StatsGroup *commentsPostsResult = [StatsGroup new];
        commentsPostsResult.items = items.lastObject;
        commentsPostsResult.errorWhileRetrieving = error != nil;
        
        if (!cacheDictionary) {
            cacheDictionary[@(StatsCacheCommentsAuthors)] = commentsAuthorsResult;
            cacheDictionary[@(StatsCacheCommentsPosts)] = commentsPostsResult;
        }
        
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(commentsAuthorsResult, error);
        }
        
        if (commentsPostsCompletion) {
            commentsPostsCompletion(commentsPostsResult, error);
        }
    };
}


- (StatsRemoteItemsCompletion)remoteFollowersCompletionWithCache:(NSMutableDictionary *)cacheDictionary cacheType:(StatsCache)cacheType andCompletionHandler:(StatsGroupCompletion)groupCompletion
{
    return ^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *followersResult = [StatsGroup new];
        followersResult.items = items;
        followersResult.moreItemsExist = moreViewsAvailable;
        followersResult.totalCount = totalViews;
        followersResult.errorWhileRetrieving = error != nil;
        
        cacheDictionary[@(cacheType)] = followersResult;
        
        for (StatsItem *item in items) {
            NSString *age = [self dateAgeForDate:item.date];
            item.value = age;
        }
        
        if (groupCompletion) {
            groupCompletion(followersResult, error);
        }
    };
}


#pragma mark - Private helper methods


// TODO - Extract this into a separate class that's unit testable
- (NSString *)dateAgeForDate:(NSDate *)date
{
    if (!date) {
        return @"";
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now = [NSDate date];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay
                                                   fromDate:date
                                                     toDate:now
                                                    options:0];
    NSDateComponents *niceDateComponents = [calendar components:NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                       fromDate:date
                                                         toDate:now
                                                        options:0];
    
    if (dateComponents.day >= 548) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d years", @"Age between dates over one year."), niceDateComponents.year];
    } else if (dateComponents.day >= 345) {
        return NSLocalizedString(@"a year", @"Age between dates equaling one year.");
    } else if (dateComponents.day >= 45) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d months", @"Age between dates over one month."), niceDateComponents.month];
    } else if (dateComponents.day >= 25) {
        return NSLocalizedString(@"a month", @"Age between dates equaling one month.");
    } else if (dateComponents.day > 1 || (dateComponents.day == 1 && dateComponents.hour >= 12)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d days", @"Age between dates over one day."), niceDateComponents.day];
    } else if (dateComponents.hour >= 22) {
        return NSLocalizedString(@"a day", @"Age between dates equaling one day.");
    } else if (dateComponents.hour > 1 || (dateComponents.hour == 1 && dateComponents.minute >= 30)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d hours", @"Age between dates over one hour."), niceDateComponents.hour];
    } else if (dateComponents.minute >= 45) {
        return NSLocalizedString(@"an hour", @"Age between dates equaling one hour.");
    } else {
        return NSLocalizedString(@"<1 hour", @"Age between dates less than one hour.");
    }
}


- (StatsDateUtilities *)dateUtilities
{
    if (!_dateUtilities) {
        _dateUtilities = [[StatsDateUtilities alloc] init];
    }
    
    return _dateUtilities;
}

@end
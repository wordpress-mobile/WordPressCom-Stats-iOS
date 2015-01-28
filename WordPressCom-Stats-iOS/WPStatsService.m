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
    NSMutableDictionary *cacheDictionary = [self.ephemory objectForKey:@[@"BatchStats", @(unit), endDate]];
    DDLogVerbose(@"Cache count: %@", @(cacheDictionary.count));
    
    if (cacheDictionary && cacheDictionary.count == 13) {
        if (visitsCompletion) {
            visitsCompletion(cacheDictionary[@(StatsSectionGraph)], nil);
        }

        if (eventsCompletion) {
            eventsCompletion(cacheDictionary[@(StatsSectionEvents)], nil);
        }

        if (postsCompletion) {
            postsCompletion(cacheDictionary[@(StatsSectionPosts)], nil);
        }
    
        if (referrersCompletion) {
            referrersCompletion(cacheDictionary[@(StatsSectionReferrers)], nil);
        }
    
        if (clicksCompletion) {
            clicksCompletion(cacheDictionary[@(StatsSectionClicks)], nil);
        }
    
        if (countryCompletion) {
            countryCompletion(cacheDictionary[@(StatsSectionCountry)], nil);
        }
    
        if (videosCompletion) {
            videosCompletion(cacheDictionary[@(StatsSectionVideos)], nil);
        }
    
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(cacheDictionary[@(StatsSubSectionCommentsByAuthor)], nil);
        }
        
        if (commentsPostsCompletion) {
            commentsPostsCompletion(cacheDictionary[@(StatsSubSectionCommentsByPosts)], nil);
        }
    
        if (tagsCategoriesCompletion) {
            tagsCategoriesCompletion(cacheDictionary[@(StatsSectionTagsCategories)], nil);
        }
    
        if (followersDotComCompletion) {
            followersDotComCompletion(cacheDictionary[@(StatsSubSectionFollowersDotCom)], nil);
        }
    
        if (followersEmailCompletion) {
            followersEmailCompletion(cacheDictionary[@(StatsSubSectionFollowersEmail)], nil);
        }
    
        if (publicizeCompletion) {
            publicizeCompletion(cacheDictionary[@(StatsSectionPublicize)], nil);
        }
        
        completionHandler();
        
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
              commentsCompletionHandler:[self remoteCommentsCompletionWithCache:cacheDictionary andCommentsAuthorsCompletion:commentsAuthorsCompletion commentsPostsCompletion:commentsPostsCompletion]
        tagsCategoriesCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionTagsCategories andCompletionHandler:tagsCategoriesCompletion]
       followersDotComCompletionHandler:[self remoteFollowersCompletionWithCache:cacheDictionary followerType:StatsFollowerTypeDotCom andCompletionHandler:followersDotComCompletion]
        followersEmailCompletionHandler:[self remoteFollowersCompletionWithCache:cacheDictionary followerType:StatsFollowerTypeEmail andCompletionHandler:followersEmailCompletion]
             publicizeCompletionHandler:[self remoteItemCompletionWithCache:cacheDictionary forStatsSection:StatsSectionPublicize andCompletionHandler:publicizeCompletion]
            andOverallCompletionHandler:^
    {
        completionHandler();
    }];
}


- (void)retrievePostsForDate:(NSDate *)date
                     andUnit:(StatsPeriodUnit)unit
       withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchPostsStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionPosts andCompletionHandler:completionHandler]];
}


- (void)retrieveReferrersForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchReferrersStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionReferrers andCompletionHandler:completionHandler]];
}


- (void)retrieveClicksForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchClicksStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil  forStatsSection:StatsSectionClicks andCompletionHandler:completionHandler]];
}


- (void)retrieveCountriesForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchCountryStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil  forStatsSection:StatsSectionCountry andCompletionHandler:completionHandler]];
}


- (void)retrieveVideosForDate:(NSDate *)date
                      andUnit:(StatsPeriodUnit)unit
        withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchVideosStatsForDate:date andUnit:unit withCompletionHandler:[self remoteItemCompletionWithCache:nil forStatsSection:StatsSectionVideos andCompletionHandler:completionHandler]];
}


- (void)retrieveFollowersOfType:(StatsFollowerType)followersType
                        forDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsGroupCompletion)completionHandler
{
    [self.remote fetchFollowersStatsForFollowerType:followersType date:date andUnit:unit withCompletionHandler:[self remoteFollowersCompletionWithCache:nil followerType:followersType andCompletionHandler:completionHandler]];
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
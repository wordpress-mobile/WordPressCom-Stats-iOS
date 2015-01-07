#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsGroup.h"
#import "StatsVisits.h"
#import "StatsSummary.h"
#import "StatsEphemory.h"

typedef NS_ENUM(NSInteger, StatsCache) {
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

@end

@implementation WPStatsService
{

}

- (instancetype)initWithSiteId:(NSNumber *)siteId siteTimeZone:(NSTimeZone *)timeZone andOAuth2Token:(NSString *)oauth2Token
{
    NSAssert(oauth2Token.length > 0, @"OAuth2 token must not be empty.");
    NSAssert(siteId != nil, @"Site ID must not be nil.");
    NSAssert(timeZone != nil, @"Timezone must not be nil.");

    self = [super init];
    if (self) {
        _siteId = siteId;
        _oauth2Token = oauth2Token;
        _siteTimeZone = timeZone ?: [NSTimeZone systemTimeZone];
        _ephemory = [StatsEphemory new];
    }

    return self;
}

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
     andOverallCompletionHandler:(void (^)())completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    NSDate *endDate = [self calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
    NSMutableDictionary *cacheDictionary = [self.ephemory objectForKey:@[@(unit), endDate]];
    if (cacheDictionary) {
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

    [self.remote batchFetchStatsForDate:endDate
                                andUnit:unit
            withVisitsCompletionHandler:^(StatsVisits *visits, NSError *error)
     {
         cacheDictionary[@(StatsCacheVisits)] = visits;
         
         if (visitsCompletion) {
             visitsCompletion(visits, error);
         }
     }
                 eventsCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *eventsResult = [StatsGroup new];
         eventsResult.items = items;
         eventsResult.moreItemsExist = moreViewsAvailable;
         eventsResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCacheEvents)] = eventsResult;
         
         if (eventsCompletion) {
             eventsCompletion(eventsResult, error);
         }
     }
                  postsCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *postsResult = [StatsGroup new];
         postsResult.items = items;
         postsResult.titlePrimary = NSLocalizedString(@"Posts & Pages", @"Title for stats section for Posts & Pages");
         postsResult.moreItemsExist = moreViewsAvailable;
         postsResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCachePosts)] = postsResult;

         if (postsCompletion) {
             postsCompletion(postsResult, error);
         }
     }
             referrersCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *referrersResult = [StatsGroup new];
         referrersResult.items = items;
         referrersResult.moreItemsExist = moreViewsAvailable;
		 referrersResult.errorWhileRetrieving = error != nil;
		 
         cacheDictionary[@(StatsCacheReferrers)] = referrersResult;

         if (referrersCompletion) {
             referrersCompletion(referrersResult, error);
         }
     }
                clicksCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *clicksResult = [StatsGroup new];
         clicksResult.items = items;
         clicksResult.moreItemsExist = moreViewsAvailable;
         clicksResult.errorWhileRetrieving = error != nil;
		 
         cacheDictionary[@(StatsCacheClicks)] = clicksResult;
         
         if (clicksCompletion) {
             clicksCompletion(clicksResult, error);
         }
     }
               countryCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *countriesResult = [StatsGroup new];
         countriesResult.items = items;
         countriesResult.moreItemsExist = moreViewsAvailable;
         countriesResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCacheCountry)] = countriesResult;
         
         if (countryCompletion) {
             countryCompletion(countriesResult, error);
         }
     }
                videosCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *videosResult = [StatsGroup new];
         videosResult.items = items;
         videosResult.moreItemsExist = moreViewsAvailable;
         videosResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCacheVideos)] = videosResult;

         if (videosCompletion) {
             videosCompletion(videosResult, error);
         }
     }
              commentsCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *commentsAuthorsResult = [StatsGroup new];
         commentsAuthorsResult.items = items.firstObject;
         commentsAuthorsResult.errorWhileRetrieving = error != nil;
         cacheDictionary[@(StatsCacheCommentsAuthors)] = commentsAuthorsResult;

         StatsGroup *commentsPostsResult = [StatsGroup new];
         commentsPostsResult.items = items.lastObject;
         commentsPostsResult.errorWhileRetrieving = error != nil;
         cacheDictionary[@(StatsCacheCommentsPosts)] = commentsPostsResult;
         
         if (commentsAuthorsCompletion) {
             commentsAuthorsCompletion(commentsAuthorsResult, error);
         }
         
         if (commentsPostsCompletion) {
             commentsPostsCompletion(commentsPostsResult, error);
         }
     }
        tagsCategoriesCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *tagsCategoriesResult = [StatsGroup new];
         tagsCategoriesResult.items = items;
         tagsCategoriesResult.moreItemsExist = moreViewsAvailable;
         tagsCategoriesResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCacheTagsCategories)] = tagsCategoriesResult;

         if (tagsCategoriesCompletion) {
             tagsCategoriesCompletion(tagsCategoriesResult, error);
         }
     }
       followersDotComCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *followersDotComResult = [StatsGroup new];
         followersDotComResult.items = items;
         followersDotComResult.moreItemsExist = moreViewsAvailable;
         followersDotComResult.totalCount = totalViews;
         followersDotComResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCacheFollowersDotCom)] = followersDotComResult;

         for (StatsItem *item in items) {
             NSString *age = [self dateAgeForDate:item.date];
             item.value = age;
         }
         
         if (followersDotComCompletion) {
             followersDotComCompletion(followersDotComResult, error);
         }
     }
         followersEmailCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
     {
         StatsGroup *followersEmailResult = [StatsGroup new];
         followersEmailResult.items = items;
         followersEmailResult.moreItemsExist = moreViewsAvailable;
         followersEmailResult.totalCount = totalViews;
         followersEmailResult.errorWhileRetrieving = error != nil;

         cacheDictionary[@(StatsCacheFollowersEmail)] = followersEmailResult;

         for (StatsItem *item in items) {
             NSString *age = [self dateAgeForDate:item.date];
             item.value = age;
         }
         
         if (followersEmailCompletion) {
             followersEmailCompletion(followersEmailResult, error);
         }
     }

              publicizeCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *publicizeResult = [StatsGroup new];
        publicizeResult.items = items;
        publicizeResult.moreItemsExist = moreViewsAvailable;
        publicizeResult.errorWhileRetrieving = error != nil;

        cacheDictionary[@(StatsCachePublicize)] = publicizeResult;

        if (publicizeCompletion) {
            publicizeCompletion(publicizeResult, nil);
        }
    }
             andOverallCompletionHandler:^
    {
        completionHandler();
    }];
}


- (void)retrieveTodayStatsWithCompletionHandler:(void (^)(StatsSummaryCompletion *))completion failureHandler:(void (^)(NSError *))failureHandler
{
    void (^failure)(NSError *error) = ^void (NSError *error) {
        DDLogError(@"Error while retrieving stats: %@", error);
        
        if (failureHandler) {
            failureHandler(error);
        }
    };
    
}

- (WPStatsServiceRemote *)remote
{
    if (!_remote) {
        _remote = [[WPStatsServiceRemote alloc] initWithOAuth2Token:self.oauth2Token siteId:self.siteId andSiteTimeZone:self.siteTimeZone];
    }

    return _remote;
}

// TODO - Extract this into a separate class that's unit testable
- (NSString *)dateAgeForDate:(NSDate *)date
{
    if (!date) {
        return @"";
    }
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now = [NSDate date];
    
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                   fromDate:date
                                                     toDate:now
                                                    options:0];
    if (dateComponents.year == 1) {
        return NSLocalizedString(@"a year", @"Age between dates equaling one year.");
    } else if (dateComponents.year > 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d years", @"Age between dates over one year."), dateComponents.year];
    } else if (dateComponents.month > 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d months", @"Age between dates over one month."), dateComponents.month];
    } else if (dateComponents.month == 1) {
        return NSLocalizedString(@"a month", @"Age between dates equaling one month.");
    } else if (dateComponents.day > 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d days", @"Age between dates over one day."), dateComponents.day];
    } else if (dateComponents.day == 1) {
        return NSLocalizedString(@"a day", @"Age between dates equaling one day.");
    } else if (dateComponents.hour > 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"%d hours", @"Age between dates over one hour."), dateComponents.hour];
    } else if (dateComponents.hour == 1) {
        return NSLocalizedString(@"an hour", @"Age between dates equaling one hour.");
    } else {
        return NSLocalizedString(@"<1 hour", @"Age between dates less than one hour.");
    }
}

- (NSDate *)calculateEndDateForPeriodUnit:(StatsPeriodUnit)unit withDateWithinPeriod:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];

    if (unit == StatsPeriodUnitDay) {
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        return date;
    } else if (unit == StatsPeriodUnitMonth) {
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        dateComponents = [NSDateComponents new];
        dateComponents.day = -1;
        dateComponents.month = +1;
        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
        
        return date;
    } else if (unit == StatsPeriodUnitWeek) {
        // Weeks are Monday - Sunday
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYearForWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:date];
        NSInteger weekDay = dateComponents.weekday;
        
        if (weekDay > 1) {
            dateComponents = [NSDateComponents new];
            dateComponents.weekday = 8 - weekDay;
            date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
        }
        
        // Strip time
        dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        date = [calendar dateFromComponents:dateComponents];

        return date;
    } else if (unit == StatsPeriodUnitYear) {
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        dateComponents = [NSDateComponents new];
        dateComponents.day = -1;
        dateComponents.year = +1;
        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
        
        return date;
    }
    
    return nil;
}

@end
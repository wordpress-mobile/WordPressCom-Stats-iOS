#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsGroup.h"
#import "StatsVisits.h"
#import "StatsSummary.h"

@interface WPStatsService ()

@property (nonatomic, strong) NSNumber *siteId;
@property (nonatomic, strong) NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;

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
    }

    return self;
}

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
     andOverallCompletionHandler:(void (^)())completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    NSMutableArray *endDates = [NSMutableArray new];
    for (NSDate *date in dates) {
        NSDate *endDate = [self calculateEndDateForPeriodUnit:unit withDateWithinPeriod:date];
        [endDates addObject:endDate];
    }

    [self.remote batchFetchStatsForDates:endDates
                                 andUnit:unit
             withVisitsCompletionHandler:^(StatsVisits *visits, NSError *error)
    {
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

        if (videosCompletion) {
            videosCompletion(videosResult, error);
        }
    }
               commentsCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *commentsAuthorsResult = [StatsGroup new];
        commentsAuthorsResult.items = items.firstObject;
        commentsAuthorsResult.errorWhileRetrieving = error != nil;
        StatsGroup *commentsPostsResult = [StatsGroup new];
        commentsPostsResult.items = items.lastObject;
        commentsPostsResult.errorWhileRetrieving = error != nil;
        
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(commentsAuthorsResult, error);
        }
        
        if (commentsPostsResult) {
            commentsPostsCompletion(commentsPostsResult, error);
        }
    }
         tagsCategoriesCompletionHandler:^(NSArray *items, NSString *totalViews, BOOL moreViewsAvailable, NSError *error)
    {
        StatsGroup *tagsCategoriesResult = [StatsGroup new];
        tagsCategoriesResult.items = items;
        tagsCategoriesResult.moreItemsExist = moreViewsAvailable;
        tagsCategoriesResult.errorWhileRetrieving = error != nil;

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
    if (unit == StatsPeriodUnitDay) {
        return date;
    }
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];

    if (unit == StatsPeriodUnitMonth) {
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
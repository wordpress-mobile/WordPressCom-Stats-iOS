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
           overallFailureHandler:(void (^)(NSError *error))failureHandler
{
    if (!completionHandler) {
        return;
    }
    
    void (^failure)(NSError *error) = ^void (NSError *error) {
        DDLogError(@"Error while retrieving stats: %@", error);

        if (failureHandler) {
            failureHandler(error);
        }
    };

    __block StatsVisits *visitsResult = nil;
    __block StatsGroup *postsResult = [StatsGroup new];
    __block StatsGroup *referrersResult = [StatsGroup new];
    __block StatsGroup *clicksResult = [StatsGroup new];
    __block StatsGroup *countriesResult = [StatsGroup new];
    __block StatsGroup *videosResult = [StatsGroup new];
    __block StatsGroup *commentsAuthorsResult = [StatsGroup new];
    __block StatsGroup *commentsPostsResult = [StatsGroup new];
    __block StatsGroup *tagsCategoriesResult = [StatsGroup new];
    __block StatsGroup *followersDotComResult = [StatsGroup new];
    __block StatsGroup *followersEmailResult = [StatsGroup new];
    __block StatsGroup *publicizeResult = [StatsGroup new];
    
    [self.remote batchFetchStatsForDates:dates
                                 andUnit:unit
             withVisitsCompletionHandler:^(StatsVisits *visits)
    {
        visitsResult = visits;
        
        if (visitsCompletion) {
            visitsCompletion(visits);
        }
    }
                  postsCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        postsResult.items = items;
        postsResult.titlePrimary = NSLocalizedString(@"Posts & Pages", @"Title for stats section for Posts & Pages");
        
        if (postsCompletion) {
            postsCompletion(postsResult);
        }
    }
              referrersCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        referrersResult.items = items;
        
        if (referrersCompletion) {
            referrersCompletion(referrersResult);
        }
    }
                 clicksCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        clicksResult.items = items;
        
        if (clicksCompletion) {
            clicksCompletion(clicksResult);
        }
    }
                countryCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        countriesResult.items = items;
        
        if (countryCompletion) {
            countryCompletion(countriesResult);
        }
    }
                 videosCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        videosResult.items = items;
        
        if (videosCompletion) {
            videosCompletion(videosResult);
        }
    }
               commentsCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        commentsAuthorsResult.items = items.firstObject;
        commentsPostsResult.items = items.lastObject;
        
        if (commentsAuthorsCompletion) {
            commentsAuthorsCompletion(commentsAuthorsResult);
        }
        
        if (commentsPostsResult) {
            commentsPostsCompletion(commentsPostsResult);
        }
    }
         tagsCategoriesCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        tagsCategoriesResult.items = items;
        
        if (tagsCategoriesCompletion) {
            tagsCategoriesCompletion(tagsCategoriesResult);
        }
    }
        followersDotComCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
     {
         followersDotComResult.items = items;
         
         for (StatsItem *item in items) {
             NSString *age = [self dateAgeForDate:item.date];
             item.value = age;
         }
         
         if (followersDotComCompletion) {
             followersDotComCompletion(followersDotComResult);
         }
     }
         followersEmailCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
     {
         followersEmailResult.items = items;
         
         for (StatsItem *item in items) {
             NSString *age = [self dateAgeForDate:item.date];
             item.value = age;
         }
         
         if (followersEmailCompletion) {
             followersEmailCompletion(followersEmailResult);
         }
     }
              publicizeCompletionHandler:^(NSArray *items, NSString *totalViews, NSString *otherViews)
    {
        publicizeResult.items = items;
        
        if (publicizeCompletion) {
            publicizeCompletion(publicizeResult);
        }
    }
             andOverallCompletionHandler:^
    {
        completionHandler();
    }
                   overallFailureHandler:failure];
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
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
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

@end
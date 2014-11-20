#import "WPStatsServiceV2.h"
#import "WPStatsServiceV2Remote.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "StatsGroup.h"
#import "StatsVisits.h"
#import "StatsSummary.h"

@interface WPStatsServiceV2 ()

@property (nonatomic, strong) NSNumber *siteId;
@property (nonatomic, strong) NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;

@end

@implementation WPStatsServiceV2
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
    withSummaryCompletionHandler:(StatsSummaryCompletion)summaryCompletion
         visitsCompletionHandler:(StatsVisitsCompletion)visitsCompletion
          postsCompletionHandler:(StatsItemsCompletion)postsCompletion
      referrersCompletionHandler:(StatsItemsCompletion)referrersCompletion
         clicksCompletionHandler:(StatsItemsCompletion)clicksCompletion
        countryCompletionHandler:(StatsItemsCompletion)countryCompletion
          videosCompetionHandler:(StatsItemsCompletion)videosCompletion
              commentsCompletion:(StatsItemsCompletion)commentsCompletion
        tagsCategoriesCompletion:(StatsItemsCompletion)tagsCategoriesCompletion
             followersCompletion:(StatsItemsCompletion)followersCompletion
             publicizeCompletion:(StatsItemsCompletion)publicizeCompletion
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

    NSDate *today = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *yesterday = [calendar dateByAddingComponents:dateComponents toDate:today options:0];

    __block StatsSummary *summaryResult = nil;
    __block StatsVisits *visitsResult = nil;
    __block StatsGroup *postsResult = [StatsGroup new];
    __block StatsGroup *referrersResult = [StatsGroup new];
    __block StatsGroup *clicksResult = [StatsGroup new];
    __block StatsGroup *countriesResult = [StatsGroup new];
    __block StatsGroup *videosResult = [StatsGroup new];
    __block StatsGroup *commentsResult = [StatsGroup new];
    __block StatsGroup *tagsCategoriesResult = [StatsGroup new];
    __block StatsGroup *followersResult = [StatsGroup new];
    __block StatsGroup *publicizeResult = [StatsGroup new];
    
    [_remote batchFetchStatsForDates:@[today]
                             andUnit:StatsPeriodUnitDay
        withSummaryCompletionHandler:^(StatsSummary *summary)
    {
        summaryResult = summary;
    }
             visitsCompletionHandler:^(StatsVisits *visits)
    {
        visitsResult = visits;
    }
              postsCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        postsResult.items = items;
    }
          referrersCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        referrersResult.items = items;
    }
             clicksCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        clicksResult.items = items;
    }
            countryCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        countriesResult.items = items;
    }
              videosCompetionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        videosResult.items = items;
    }
                  commentsCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        commentsResult.items = items;
    }
            tagsCategoriesCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        tagsCategoriesResult.items = items;
    }
                 followersCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        followersResult.items = items;
    }
                 publicizeCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        publicizeResult.items = items;
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

- (WPStatsServiceV2Remote *)remote
{
    if (!_remote) {
        _remote = [[WPStatsServiceV2Remote alloc] initWithOAuth2Token:self.oauth2Token siteId:self.siteId andSiteTimeZone:self.siteTimeZone];
    }

    return _remote;
}

@end
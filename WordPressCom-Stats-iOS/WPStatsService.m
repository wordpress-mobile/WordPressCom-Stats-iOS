#import "WPStatsService.h"
#import "WPStatsServiceV2Remote.h"
#import "WPStatsTitleCountItem.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "WPStatsTopPost.h"

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

- (void)retrieveAllStatsWithCompletionHandler:(StatsCompletion)completion failureHandler:(void (^)(NSError *error))failureHandler
{
    if (!completion) {
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

//    typedef void (^StatsCompletion)(WPStatsSummary *summary, NSDictionary *topPosts, NSDictionary *clicks, NSDictionary *countryViews, NSDictionary *referrers, NSDictionary *searchTerms, WPStatsViewsVisitors *viewsVisitors);

    __block WPStatsSummary *summaryResult = [WPStatsSummary new];
    __block NSDictionary *topPosts = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSMutableDictionary *clicks = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSMutableDictionary *countryViews = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSMutableDictionary *referrers = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSMutableDictionary *searchTerms = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block WPStatsViewsVisitors *viewsVisitors = [WPStatsViewsVisitors new];
    
    [self.remote batchFetchStatsForDates:@[yesterday, today] andUnit:StatsPeriodUnitDay withSummaryCompletionHandler:^(StatsSummary *summary) {
        summaryResult.totalCategories = @-1;
        summaryResult.totalComments = @-1;
        summaryResult.totalFollowersBlog = @-1;
        summaryResult.totalFollowersComments = @-1;
        summaryResult.totalPosts = @-1;
        summaryResult.totalShares = @-1;
        summaryResult.totalTags = @-1;
        summaryResult.totalViews = @-1;
        summaryResult.viewCountBest = @-1;
        summaryResult.viewCountToday = summary.views;
        summaryResult.visitorCountToday = summary.visitors;

    } visitsCompletionHandler:^(StatsVisits *visits) {
        
    } postsCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {
        NSMutableArray *topPostsArray = [NSMutableArray array];
        for (StatsItem *item in items) {
            WPStatsTopPost *topPost = [[WPStatsTopPost alloc] init];
            topPost.title = item.label;
            topPost.URL = [item.actions[0] url];
            topPost.count = item.value;
            [topPostsArray addObject:topPost];
        }
        
        topPosts = @{ StatsResultsToday : topPostsArray, StatsResultsYesterday : @[]};

    } referrersCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {

    } clicksCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {

    } countryCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {

    } andOverallCompletionHandler:^{
        completion(summaryResult, topPosts, clicks, countryViews, referrers, searchTerms, viewsVisitors);

    } overallFailureHandler:failure];
}

- (void)retrieveTodayStatsWithCompletionHandler:(void (^)(WPStatsSummary *))completion failureHandler:(void (^)(NSError *))failureHandler
{
    void (^failure)(NSError *error) = ^void (NSError *error) {
        DDLogError(@"Error while retrieving stats: %@", error);
        
        if (failureHandler) {
            failureHandler(error);
        }
    };
    
//    [self.remote fetchSummaryStatsForTodayWithCompletionHandler:completion
//                                                 failureHandler:failure];
    
    // TODO :: Replace date below for proper "Today" calculation
    [self.remote fetchSummaryStatsForDate:[NSDate date]
                    withCompletionHandler:^(StatsSummary *summary) {
        WPStatsSummary *summaryResult = [WPStatsSummary new];
        summaryResult.totalCategories = @-1;
        summaryResult.totalComments = @-1;
        summaryResult.totalFollowersBlog = @-1;
        summaryResult.totalFollowersComments = @-1;
        summaryResult.totalPosts = @-1;
        summaryResult.totalShares = @-1;
        summaryResult.totalTags = @-1;
        summaryResult.totalViews = @-1;
        summaryResult.viewCountBest = @-1;
        summaryResult.viewCountToday = summary.views;
        summaryResult.visitorCountToday = summary.visitors;
        
        if (completion) {
            completion(summaryResult);
        }
    } failureHandler:failure];
}

- (WPStatsServiceV2Remote *)remote
{
    if (!_remote) {
        _remote = [[WPStatsServiceV2Remote alloc] initWithOAuth2Token:self.oauth2Token siteId:self.siteId andSiteTimeZone:self.siteTimeZone];
    }

    return _remote;
}

@end
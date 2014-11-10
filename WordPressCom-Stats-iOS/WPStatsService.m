#import "WPStatsService.h"
#import "WPStatsServiceV2Remote.h"
#import "WPStatsTitleCountItem.h"
#import "StatsItem.h"
#import "StatsItemAction.h"
#import "WPStatsTopPost.h"
#import "WPStatsGroup.h"
#import "WPStatsTitleCountItem.h"
#import "WPStatsViewsVisitors.h"

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

    __block WPStatsSummary *summaryResult = [WPStatsSummary new];
    __block NSDictionary *topPosts = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSDictionary *clicks = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSDictionary *countryViews = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
    __block NSDictionary *referrers = [@{StatsResultsToday : @[], StatsResultsYesterday : @[]} mutableCopy];
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
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd";
        formatter.timeZone = self.siteTimeZone;
        
        NSMutableArray *data = [NSMutableArray new];
        for (StatsSummary *summary in visits.statsData) {
            NSString *dateString = [formatter stringFromDate:summary.date];
            [data addObject:@[dateString, summary.views, summary.visitors]];
        }
        
        NSDictionary *dataDict = @{ @"data" :  data};
        [viewsVisitors addViewsVisitorsWithData:dataDict unit:StatsViewsVisitorsUnitDay];

    } postsCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {
        // TODO - Handle today vs yesterday
        
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
        // TODO - Handle today vs yesterday
        
        NSMutableArray *referrersArray = [NSMutableArray new];
        for (StatsItem *item in items) {
            WPStatsGroup *statsGroup = [WPStatsGroup new];
            statsGroup.title = item.label;
            statsGroup.iconUrl = item.iconURL;
            statsGroup.count = item.value;
            
            NSMutableArray *children = [NSMutableArray new];
            for (StatsItem *childItem in item.children) {
                WPStatsTitleCountItem *titleItem = [WPStatsTitleCountItem new];
                titleItem.title = childItem.label;
                titleItem.URL = [childItem.actions[0] url];
                titleItem.count = childItem.value;
                
                [children addObject:titleItem];
            }
            statsGroup.children = children;
            [referrersArray addObject:statsGroup];
        }
        
        referrers = @{ StatsResultsToday : referrersArray, StatsResultsYesterday : @[]};

    } clicksCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {
        // TODO - Handle today vs yesterday
        
        NSMutableArray *clicksArray = [NSMutableArray new];
        for (StatsItem *item in items) {
            WPStatsGroup *statsGroup = [WPStatsGroup new];
            statsGroup.title = item.label;
            statsGroup.iconUrl = item.iconURL;
            statsGroup.count = item.value;
            
            NSMutableArray *children = [NSMutableArray new];
            for (StatsItem *childItem in item.children) {
                WPStatsTitleCountItem *titleItem = [WPStatsTitleCountItem new];
                titleItem.title = childItem.label;
                titleItem.URL = [childItem.actions[0] url];
                titleItem.count = childItem.value;
                
                [children addObject:titleItem];
            }
            statsGroup.children = children;
            [clicksArray addObject:statsGroup];
        }
        
        clicks = @{ StatsResultsToday : clicksArray, StatsResultsYesterday : @[]};
        
    } countryCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews) {
        // TODO - Handle today vs yesterday
        
        NSMutableArray *countryArray = [NSMutableArray new];
        for (StatsItem *item in items) {
            WPStatsGroup *statsGroup = [WPStatsGroup new];
            statsGroup.title = item.label;
            statsGroup.iconUrl = item.iconURL;
            statsGroup.count = item.value;
            
            NSMutableArray *children = [NSMutableArray new];
            for (StatsItem *childItem in item.children) {
                WPStatsTitleCountItem *titleItem = [WPStatsTitleCountItem new];
                titleItem.title = childItem.label;
                titleItem.URL = [childItem.actions[0] url];
                titleItem.count = childItem.value;
                
                [children addObject:titleItem];
            }
            statsGroup.children = children;
            [countryArray addObject:statsGroup];
        }
        
        countryViews = @{ StatsResultsToday : countryArray, StatsResultsYesterday : @[]};
        
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
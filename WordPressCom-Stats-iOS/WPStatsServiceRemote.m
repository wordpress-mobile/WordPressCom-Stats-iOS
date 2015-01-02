#import "WPStatsServiceRemote.h"
#import "NSObject+SafeExpectations.h"
#import "NSDictionary+SafeExpectations.h"
#import <AFNetworking/AFNetworking.h>
#import "StatsItem.h"
#import "StatsItemAction.h"
#import <NSObject+SafeExpectations.h>

static NSString *const WordPressComApiClientEndpointURL = @"https://public-api.wordpress.com/rest/v1.1";

@interface WPStatsServiceRemote ()

@property (nonatomic, copy)     NSString                        *oauth2Token;
@property (nonatomic, strong)   NSNumber                        *siteId;
@property (nonatomic, strong)   NSTimeZone                      *siteTimeZone;
@property (nonatomic, copy)     NSString                        *statsPathPrefix;
@property (nonatomic, copy)     NSString                        *sitesPathPrefix;
@property (nonatomic, strong)   NSDateFormatter                 *deviceDateFormatter;
@property (nonatomic, strong)   NSDateFormatter                 *rfc3339DateFormatter;
@property (nonatomic, strong)   NSNumberFormatter               *deviceNumberFormatter;
@property (nonatomic, strong)   AFHTTPRequestOperationManager   *manager;

@end

@implementation WPStatsServiceRemote {
    
}

- (instancetype)initWithOAuth2Token:(NSString *)oauth2Token siteId:(NSNumber *)siteId andSiteTimeZone:(NSTimeZone *)timeZone
{
    NSParameterAssert(oauth2Token.length > 0);
    NSParameterAssert(siteId != nil);
    NSParameterAssert(timeZone != nil);
    
    self = [super init];
    if (self) {
        _oauth2Token = oauth2Token;
        _siteId = siteId;
        _siteTimeZone = timeZone;
        _sitesPathPrefix = [NSString stringWithFormat:@"%@/sites/%@", WordPressComApiClientEndpointURL, _siteId];
        _statsPathPrefix = [NSString stringWithFormat:@"%@/sites/%@/stats", WordPressComApiClientEndpointURL, _siteId];
        
        _deviceDateFormatter = [NSDateFormatter new];
        _deviceDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _deviceDateFormatter.dateFormat = @"yyyy-MM-dd";
        
        _deviceNumberFormatter = [NSNumberFormatter new];
        
        _rfc3339DateFormatter = [[NSDateFormatter alloc] init];
        _rfc3339DateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _rfc3339DateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
        _rfc3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", _oauth2Token]
                          forHTTPHeaderField:@"Authorization"];
    }
    
    return self;
}


#pragma mark - Public methods


- (void)batchFetchStatsForDates:(NSArray *)dates
                        andUnit:(StatsPeriodUnit)unit
    withVisitsCompletionHandler:(StatsRemoteVisitsCompletion)visitsCompletion
        eventsCompletionHandler:(StatsRemoteItemsCompletion)eventsCompletion
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
          overallFailureHandler:(void (^)(NSError *error))failureHandler
{
    NSMutableArray *mutableOperations = [NSMutableArray new];
    
    for (NSDate *date in dates) {
        if (visitsCompletion) {
            [mutableOperations addObject:[self operationForVisitsForDate:date andUnit:unit withCompletionHandler:visitsCompletion failureHandler:nil]];
        }
        if (eventsCompletion) {
            [mutableOperations addObject:[self operationForEventsForDate:date andUnit:unit withCompletionHandler:eventsCompletion failureHandler:nil]];
        }
        if (postsCompletion) {
            [mutableOperations addObject:[self operationForPostsForDate:date andUnit:unit withCompletionHandler:postsCompletion failureHandler:nil]];
        }
        if (referrersCompletion) {
            [mutableOperations addObject:[self operationForReferrersForDate:date andUnit:unit withCompletionHandler:referrersCompletion failureHandler:nil]];
        }
        if (clicksCompletion) {
            [mutableOperations addObject:[self operationForClicksForDate:date andUnit:unit withCompletionHandler:clicksCompletion failureHandler:nil]];
        }
        if (countryCompletion) {
            [mutableOperations addObject:[self operationForCountryForDate:date andUnit:unit withCompletionHandler:countryCompletion failureHandler:nil]];
        }
        if (videosCompletion) {
            [mutableOperations addObject:[self operationForVideosForDate:date andUnit:unit withCompletionHandler:videosCompletion failureHandler:nil]];
        }
        if (commentsCompletion) {
            [mutableOperations addObject:[self operationForCommentsForDate:date andUnit:unit withCompletionHandler:commentsCompletion failureHandler:nil]];
        }
        if (tagsCategoriesCompletion) {
            [mutableOperations addObject:[self operationForTagsCategoriesForDate:date andUnit:unit withCompletionHandler:tagsCategoriesCompletion failureHandler:nil]];
        }
        if (followersDotComCompletion) {
            [mutableOperations addObject:[self operationForFollowersOfType:StatsFollowerTypeDotCom forDate:date andUnit:unit withCompletionHandler:followersDotComCompletion failureHandler:nil]];
        }
        if (followersEmailCompletion) {
            [mutableOperations addObject:[self operationForFollowersOfType:StatsFollowerTypeEmail forDate:date andUnit:unit withCompletionHandler:followersEmailCompletion failureHandler:nil]];
        }
        if (publicizeCompletion) {
            [mutableOperations addObject:[self operationForPublicizeForDate:date andUnit:unit withCompletionHandler:publicizeCompletion failureHandler:nil]];
        }
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        DDLogVerbose(@"Finished remote operations %@ of %@", @(numberOfFinishedOperations), @(totalNumberOfOperations));
    } completionBlock:^(NSArray *operations) {
        if (completionHandler) {
            completionHandler();
        }
    }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (void)fetchSummaryStatsForDate:(NSDate *)date
           withCompletionHandler:(StatsRemoteSummaryCompletion)completionHandler
                  failureHandler:(void (^)(NSError *error))failureHandler
{
    AFHTTPRequestOperation *operation = [self operationForSummaryForDate:date andUnit:StatsPeriodUnitDay withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchVisitsStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteVisitsCompletion)completionHandler
                 failureHandler:(void (^)(NSError *error))failureHandler
{
    
    AFHTTPRequestOperation *operation = [self operationForVisitsForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchEventsForDate:(NSDate *)date
                   andUnit:(StatsPeriodUnit)unit
     withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
            failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForEventsForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchPostsStatsForDate:(NSDate *)date
                       andUnit:(StatsPeriodUnit)unit
         withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForPostsForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchReferrersStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                    failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForReferrersForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchClicksStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                 failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForClicksForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchCountryStatsForDate:(NSDate *)date
                         andUnit:(StatsPeriodUnit)unit
           withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                  failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForCountryForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchVideosStatsForDate:(NSDate *)date
                        andUnit:(StatsPeriodUnit)unit
          withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                 failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForVideosForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchCommentsStatsForDate:(NSDate *)date
                          andUnit:(StatsPeriodUnit)unit
            withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                   failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForCommentsForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchTagsCategoriesStatsForDate:(NSDate *)date
                                andUnit:(StatsPeriodUnit)unit
                  withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                         failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForTagsCategoriesForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchFollowersStatsForFollowerType:(StatsFollowerType)followerType
                                      date:(NSDate *)date
                                   andUnit:(StatsPeriodUnit)unit
                     withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                            failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForFollowersOfType:followerType forDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


- (void)fetchPublicizeStatsForDate:(NSDate *)date
                           andUnit:(StatsPeriodUnit)unit
             withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                    failureHandler:(void (^)(NSError *error))failureHandler
{
    NSParameterAssert(date != nil);
    
    AFHTTPRequestOperation *operation = [self operationForPublicizeForDate:date andUnit:unit withCompletionHandler:completionHandler failureHandler:failureHandler];
    [operation start];
}


#pragma mark - Private methods to compose request operations to be reusable


- (AFHTTPRequestOperation *)operationForSummaryForDate:(NSDate *)date
                                               andUnit:(StatsPeriodUnit)unit
                                 withCompletionHandler:(StatsRemoteSummaryCompletion)completionHandler
                                        failureHandler:(void (^)(NSError *error))failureHandler
{
    
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *statsSummaryDict = (NSDictionary *)responseObject;
        StatsSummary *statsSummary = [StatsSummary new];
        statsSummary.periodUnit = [self periodUnitForString:statsSummaryDict[@"period"]];
        statsSummary.date = [self deviceLocalDateForString:statsSummaryDict[@"date"] withPeriodUnit:unit];
        statsSummary.label = [self nicePointNameForDate:statsSummary.date forStatsPeriodUnit:statsSummary.periodUnit];
        statsSummary.views = [self localizedStringForNumber:[statsSummaryDict numberForKey:@"views"]];
        statsSummary.visitors = [self localizedStringForNumber:[statsSummaryDict numberForKey:@"visitors"]];
        statsSummary.likes = [self localizedStringForNumber:[statsSummaryDict numberForKey:@"likes"]];
        statsSummary.comments = [self localizedStringForNumber:[statsSummaryDict numberForKey:@"comments"]];
        
        if (completionHandler) {
            completionHandler(statsSummary);
        }
    };
    
    AFHTTPRequestOperation *operation =  [self requestOperationForURLString:[self urlForSummary]
                                                                 parameters:nil
                                                                    success:handler
                                                                    failure:[self failureForFailureCompletionHandler:failureHandler]];
    return operation;
}


- (AFHTTPRequestOperation *)operationForVisitsForDate:(NSDate *)date
                                              andUnit:(StatsPeriodUnit)unit
                                withCompletionHandler:(StatsRemoteVisitsCompletion)completionHandler
                                       failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *statsVisitsDict = (NSDictionary *)responseObject;
        
        StatsVisits *statsVisits = [StatsVisits new];
        statsVisits.date = [self deviceLocalDateForString:statsVisitsDict[@"date"] withPeriodUnit:unit];
        
        NSArray *fields = (NSArray *)statsVisitsDict[@"fields"];
        
        NSUInteger periodIndex = [fields indexOfObject:@"period"];
        NSUInteger viewsIndex = [fields indexOfObject:@"views"];
        NSUInteger visitorsIndex = [fields indexOfObject:@"visitors"];
        NSUInteger likesIndex = [fields indexOfObject:@"likes"];
        NSUInteger commentsIndex = [fields indexOfObject:@"comments"];
        
        NSMutableArray *array = [NSMutableArray new];
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        for (NSArray *period in statsVisitsDict[@"data"]) {
            StatsSummary *periodSummary = [StatsSummary new];
            periodSummary.periodUnit = unit;
            periodSummary.date = [self deviceLocalDateForString:period[periodIndex] withPeriodUnit:unit];
            periodSummary.label = [self nicePointNameForDate:periodSummary.date forStatsPeriodUnit:periodSummary.periodUnit];
            periodSummary.views = [self localizedStringForNumber:period[viewsIndex]];
            periodSummary.visitors = [self localizedStringForNumber:period[visitorsIndex]];
            periodSummary.likes = [self localizedStringForNumber:period[likesIndex]];
            periodSummary.comments = [self localizedStringForNumber:period[commentsIndex]];
            [array addObject:periodSummary];
            dictionary[periodSummary.date] = periodSummary;
        }
        
        statsVisits.statsData = array;
        statsVisits.statsDataByDate = dictionary;
        
        if (completionHandler) {
            completionHandler(statsVisits);
        }
    };
    
    // TODO :: Abstract this out to the local service
    NSNumber *quantity = IS_IPAD ? @12 : @7;
    NSDictionary *parameters = @{@"quantity" : quantity,
                                 @"unit"     : [self stringForPeriodUnit:unit],
                                 @"date"     : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation =  [self requestOperationForURLString:[self urlForVisits]
                                                                 parameters:parameters
                                                                    success:handler
                                                                    failure:[self failureForFailureCompletionHandler:failureHandler]];
    return operation;
}


- (AFHTTPRequestOperation *)operationForEventsForDate:(NSDate *)date
                                              andUnit:(StatsPeriodUnit)unit
                                withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                       failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        // TODO :: Implement
        
        if (completionHandler) {
//            completionHandler(items, totalViews, moreViewsAvailable);
        }
    };
    
    // TODO : Calculate date range with period
    NSDictionary *parameters = @{@"after"   : [self siteLocalStringForDate:date],
                                 @"before"  : [self siteLocalStringForDate:date],
                                 @"number"  : @10};
    AFHTTPRequestOperation *operation =  [self requestOperationForURLString:[self urlForPosts]
                                                                 parameters:parameters
                                                                    success:handler
                                                                    failure:[self failureForFailureCompletionHandler:failureHandler]];
    return operation;
}


- (AFHTTPRequestOperation *)operationForPostsForDate:(NSDate *)date
                                             andUnit:(StatsPeriodUnit)unit
                               withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                      failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *statsPostsDict = (NSDictionary *)responseObject;
        NSDictionary *days = [statsPostsDict dictionaryForKey:@"days"];
        id firstKey = days.allKeys.firstObject;
        NSDictionary *firstDay = [days dictionaryForKey:firstKey];
        NSArray *postViews = [firstDay arrayForKey:@"postviews"];
        NSString *totalViews = [self localizedStringForNumber:[firstDay numberForKey:@"total_views"]];
        BOOL moreViewsAvailable = [firstDay numberForKey:@"other_views"].integerValue > 0;
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *post in postViews) {
            StatsItem *statsItem = [StatsItem new];
            statsItem.itemID = post[@"id"];
            statsItem.value = [self localizedStringForNumber:[post numberForKey:@"views"]];
            statsItem.label = [post stringForKey:@"title"];
            
            StatsItemAction *statsItemAction = [StatsItemAction new];
            statsItemAction.url = [NSURL URLWithString:post[@"href"]];
            statsItemAction.defaultAction = YES;
            
            statsItem.actions = @[statsItemAction];
            
            [items addObject:statsItem];
        }
        
        
        if (completionHandler) {
            completionHandler(items, totalViews, moreViewsAvailable);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    AFHTTPRequestOperation *operation =  [self requestOperationForURLString:[self urlForTopPosts]
                                                                 parameters:parameters
                                                                    success:handler
                                                                    failure:[self failureForFailureCompletionHandler:failureHandler]];
    return operation;
}


- (AFHTTPRequestOperation *)operationForReferrersForDate:(NSDate *)date
                                                 andUnit:(StatsPeriodUnit)unit
                                   withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                          failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *referrersDict = (NSDictionary *)responseObject;
        NSDictionary *days = [referrersDict dictionaryForKey:@"days"];
        id firstKey = days.allKeys.firstObject;
        NSDictionary *firstDay = [days dictionaryForKey:firstKey];
        NSArray *groups = [firstDay arrayForKey:@"groups"];
        NSString *totalViews = [self localizedStringForNumber:[firstDay numberForKey:@"total_views"]];
        BOOL moreViewsAvailable = [firstDay numberForKey:@"other_views"].integerValue > 0;
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *group in groups) {
            StatsItem *statsItem = [StatsItem new];
            statsItem.label = [group stringForKey:@"name"];
            statsItem.value = [self localizedStringForNumber:[group numberForKey:@"total"]];
            statsItem.iconURL = [NSURL URLWithString:[group stringForKey:@"icon"]];
            
            NSString *url = [group stringForKey:@"url"];
            if (url) {
                StatsItemAction *action = [StatsItemAction new];
                action.url = [NSURL URLWithString:url];
                action.defaultAction = YES;
                statsItem.actions = @[action];
            }
            
            NSArray *results = [group arrayForKey:@"results"];
            for (id result in results) {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    StatsItem *resultItem = [StatsItem new];
                    resultItem.label = [result stringForKey:@"name"];
                    resultItem.iconURL = [NSURL URLWithString:[result stringForKey:@"icon"]];
                    resultItem.value = [self localizedStringForNumber:[result numberForKey:@"views"]];
                    
                    NSString *url = [result stringForKey:@"url"];
                    if (url) {
                        StatsItemAction *action = [StatsItemAction new];
                        action.url = [NSURL URLWithString:url];
                        action.defaultAction = YES;
                        resultItem.actions = @[action];
                    }
                    
                    [statsItem addChildStatsItem:resultItem];
                    
                    NSArray *children = [result arrayForKey:@"children"];
                    for (NSDictionary *child in children) {
                        StatsItem *childItem = [StatsItem new];
                        childItem.label = [child stringForKey:@"name"];
                        childItem.iconURL = [NSURL URLWithString:[child stringForKey:@"icon"]];
                        childItem.value = [self localizedStringForNumber:[child numberForKey:@"views"]];
                        
                        NSString *url = [child stringForKey:@"url"];
                        if (url) {
                            StatsItemAction *action = [StatsItemAction new];
                            action.url = [NSURL URLWithString:url];
                            action.defaultAction = YES;
                            childItem.actions = @[action];
                        }
                        
                        [resultItem addChildStatsItem:childItem];
                    }
                }
            }
            
            [items addObject:statsItem];
        }
        
        
        if (completionHandler) {
            completionHandler(items, totalViews, moreViewsAvailable);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForReferrers]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    
    return operation;
}


- (AFHTTPRequestOperation *)operationForClicksForDate:(NSDate *)date
                                              andUnit:(StatsPeriodUnit)unit
                                withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                       failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *referrersDict = (NSDictionary *)responseObject;
        NSDictionary *days = [referrersDict dictionaryForKey:@"days"];
        id firstKey = days.allKeys.firstObject;
        NSDictionary *firstDay = [days dictionaryForKey:firstKey];
        NSArray *clicks = [firstDay arrayForKey:@"clicks"];
        NSString *totalClicks = [self localizedStringForNumber:[firstDay numberForKey:@"total_clicks"]];
        BOOL moreClicksAvailable = [firstDay numberForKey:@"other_clicks"].integerValue > 0;
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *click in clicks) {
            StatsItem *statsItem = [StatsItem new];
            statsItem.label = [click stringForKey:@"name"];
            statsItem.value = [self localizedStringForNumber:[click numberForKey:@"views"]];
            statsItem.iconURL = [NSURL URLWithString:[click stringForKey:@"icon"]];
            
            NSString *url = [click stringForKey:@"url"];
            if (url) {
                StatsItemAction *action = [StatsItemAction new];
                action.url = [NSURL URLWithString:url];
                action.defaultAction = YES;
                statsItem.actions = @[action];
            }
            
            NSArray *children = [click arrayForKey:@"children"];
            for (NSDictionary *child in children) {
                StatsItem *childItem = [StatsItem new];
                childItem.label = [child stringForKey:@"name"];
                childItem.iconURL = [NSURL URLWithString:[child stringForKey:@"icon"]];
                childItem.value = [self localizedStringForNumber:[child numberForKey:@"views"]];
                
                NSString *url = [child stringForKey:@"url"];
                if (url) {
                    StatsItemAction *action = [StatsItemAction new];
                    action.url = [NSURL URLWithString:url];
                    action.defaultAction = YES;
                    childItem.actions = @[action];
                }
                
                [statsItem addChildStatsItem:childItem];
            }
            
            [items addObject:statsItem];
        }
        
        
        if (completionHandler) {
            completionHandler(items, totalClicks, moreClicksAvailable);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForClicks]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    return operation;
}


- (AFHTTPRequestOperation *)operationForCountryForDate:(NSDate *)date
                                               andUnit:(StatsPeriodUnit)unit
                                 withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                        failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *countryViewsDict = (NSDictionary *)responseObject;
        NSDictionary *days = [countryViewsDict dictionaryForKey:@"days"];
        id firstKey = days.allKeys.firstObject;
        NSDictionary *firstDay = [days dictionaryForKey:firstKey];
        NSDictionary *countryInfoDict = [countryViewsDict dictionaryForKey:@"country-info"];
        NSArray *views = [firstDay arrayForKey:@"views"];
        NSString *totalViews = [self localizedStringForNumber:[firstDay numberForKey:@"total_views"]];
        BOOL moreViewsAvailable = [firstDay numberForKey:@"other_views"].integerValue > 0;
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *view in views) {
            NSString *key = [view stringForKey:@"country_code"];
            StatsItem *statsItem = [StatsItem new];
            statsItem.label = [countryInfoDict[key] stringForKey:@"country_full"];
            statsItem.value = [self localizedStringForNumber:[view numberForKey:@"views"]];
            statsItem.iconURL = [NSURL URLWithString:[countryInfoDict[key] stringForKey:@"flag_icon"]];
            
            [items addObject:statsItem];
        }
        
        if (completionHandler) {
            completionHandler(items, totalViews, moreViewsAvailable);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForCountryViews]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];

    return operation;
}


- (AFHTTPRequestOperation *)operationForVideosForDate:(NSDate *)date
                                              andUnit:(StatsPeriodUnit)unit
                                withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                       failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *videosDict = (NSDictionary *)responseObject;
        NSDictionary *days = [videosDict dictionaryForKey:@"days"];
        id firstKey = days.allKeys.firstObject;
        NSDictionary *firstDay = [days dictionaryForKey:firstKey];
        NSArray *playsArray = [firstDay arrayForKey:@"plays"];
        NSString *totalPlays = [self localizedStringForNumber:[firstDay numberForKey:@"total_plays"]];
        BOOL morePlaysAvailable = [firstDay numberForKey:@"other_plays"].integerValue > 0;
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *play in playsArray) {
            StatsItem *statsItem = [StatsItem new];
            statsItem.itemID = [play numberForKey:@"post_id"];
            statsItem.label = [play stringForKey:@"title"];
            statsItem.value = [self localizedStringForNumber:[play numberForKey:@"plays"]];

            NSString *url = [play stringForKey:@"url"];
            if (url) {
                StatsItemAction *action = [StatsItemAction new];
                action.url = [NSURL URLWithString:url];
                action.defaultAction = YES;
                statsItem.actions = @[action];
            }

            [items addObject:statsItem];
        }
        
        if (completionHandler) {
            completionHandler(items, totalPlays, morePlaysAvailable);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForVideos]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    
    return operation;
}


- (AFHTTPRequestOperation *)operationForCommentsForDate:(NSDate *)date
                                                andUnit:(StatsPeriodUnit)unit
                                  withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                         failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSMutableArray *authorItems = [NSMutableArray new];
        NSMutableArray *postsItems = [NSMutableArray new];
        
        NSArray *authors = [responseObject arrayForKey:@"authors"];
        NSArray *posts = [responseObject arrayForKey:@"posts"];
        
        for (NSDictionary *author in authors) {
            StatsItem *item = [StatsItem new];
            item.label = [author stringForKey:@"name"];
            item.iconURL = [NSURL URLWithString:[author stringForKey:@"gravatar"]];
            item.value = [self localizedStringForNumber:[author numberForKey:@"comments"]];
            // TODO follow data
            
            [authorItems addObject:item];
        }
        
        for (NSDictionary *post in posts) {
            StatsItem *item = [StatsItem new];
            item.label = [post stringForKey:@"name"];
            item.itemID = [post numberForKey:@"id"];
            item.value = [self localizedStringForNumber:[post numberForKey:@"comments"]];
            
            NSString *linkURL = [post stringForKey:@"link"];
            if (linkURL.length > 0) {
                StatsItemAction *itemAction = [StatsItemAction new];
                itemAction.url = [NSURL URLWithString:linkURL];
                itemAction.defaultAction = YES;
                item.actions = @[itemAction];
            }
            
            [postsItems addObject:item];
        }
        
        if (completionHandler) {
            // More not available with comments
            completionHandler(@[authorItems, postsItems], nil, false);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForComments]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    
    return operation;
}


- (AFHTTPRequestOperation *)operationForTagsCategoriesForDate:(NSDate *)date
                                                      andUnit:(StatsPeriodUnit)unit
                                        withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                               failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSArray *tagGroups = [responseDict arrayForKey:@"tags"];
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *tagGroup in tagGroups) {
            NSArray *tags = [tagGroup arrayForKey:@"tags"];
            
            if (tags.count == 1) {
                NSDictionary *theTag = tags[0];
                StatsItem *statsItem = [StatsItem new];
                statsItem.label = [theTag stringForKey:@"name"];
                statsItem.value = [self localizedStringForNumber:[tagGroup numberForKey:@"views"]];
                [items addObject:statsItem];
            } else {
                NSMutableString *tagLabel = [NSMutableString new];
                
                StatsItem *statsItem = [StatsItem new];
                for (NSDictionary *subTag in tags) {
                    
                    StatsItem *childItem = [StatsItem new];
                    childItem.label = [subTag stringForKey:@"name"];
                    
                    [tagLabel appendFormat:@"%@ ", childItem.label];
                    
                    [statsItem addChildStatsItem:childItem];
                }
                
                NSString *trimmedLabel = [tagLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                statsItem.label = trimmedLabel;
                statsItem.value = [self localizedStringForNumber:[tagGroup numberForKey:@"views"]];
                
                [items addObject:statsItem];
            }
        }
        
        if (completionHandler) {
            // More not available with tags
            completionHandler(items, nil, false);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForTagsCategories]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    return operation;}


- (AFHTTPRequestOperation *)operationForFollowersOfType:(StatsFollowerType)followerType
                                                forDate:(NSDate *)date
                                                andUnit:(StatsPeriodUnit)unit
                                  withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                         failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        NSArray *subscribers = [response arrayForKey:@"subscribers"];
        NSMutableArray *items = [NSMutableArray new];
        NSString *totalKey = followerType == StatsFollowerTypeDotCom ? @"total_wpcom" : @"total_email";
        NSString *totalFollowers = [self localizedStringForNumber:[response numberForKey:totalKey]];
        BOOL moreFollowersAvailable = [response numberForKey:@"pages"].integerValue > 1;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-mm-dd hh:mi:ss";
        
        for (NSDictionary *subscriber in subscribers) {
            StatsItem *statsItem = [StatsItem new];
            statsItem.label = [subscriber stringForKey:@"label"];
            statsItem.iconURL = [NSURL URLWithString:[subscriber stringForKey:@"avatar"]];
            statsItem.date = [self.rfc3339DateFormatter dateFromString:[subscriber stringForKey:@"date_subscribed"]];
            
            
            [items addObject:statsItem];
        }
        
        if (completionHandler) {
            completionHandler(items, totalFollowers, moreFollowersAvailable);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date],
                                 @"type"   : followerType == StatsFollowerTypeDotCom ? @"wpcom" : @"email",
                                 @"max"    : @7}; // TODO - Change this to a non-fixed value?
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForFollowers]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    
    return operation;
}


- (AFHTTPRequestOperation *)operationForPublicizeForDate:(NSDate *)date
                                                 andUnit:(StatsPeriodUnit)unit
                                   withCompletionHandler:(StatsRemoteItemsCompletion)completionHandler
                                          failureHandler:(void (^)(NSError *error))failureHandler
{
    id handler = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *servicesDict = (NSDictionary *)responseObject;
        NSArray *services = [servicesDict arrayForKey:@"services"];
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *service in services) {
            StatsItem *statsItem = [StatsItem new];
            NSString *serviceID = [service stringForKey:@"service"];
            NSString *serviceLabel = serviceID;
            NSURL *iconURL = nil;
            
            if ([serviceID isEqualToString:@"facebook"]) {
                serviceLabel = @"Facebook";
                iconURL = [NSURL URLWithString:@"https://secure.gravatar.com/blavatar/2343ec78a04c6ea9d80806345d31fd78?s=48"];
            } else if ([serviceID isEqualToString:@"twitter"]) {
                serviceLabel = @"Twitter";
                iconURL = [NSURL URLWithString:@"https://secure.gravatar.com/blavatar/7905d1c4e12c54933a44d19fcd5f9356?s=48"];
            } else if ([serviceID isEqualToString:@"tumblr"]) {
                serviceLabel = @"Tumblr";
                iconURL = [NSURL URLWithString:@"https://secure.gravatar.com/blavatar/84314f01e87cb656ba5f382d22d85134?s=48"];
            } else if ([serviceID isEqualToString:@"google_plus"]) {
                serviceLabel = @"Google+";
                iconURL = [NSURL URLWithString:@"https://secure.gravatar.com/blavatar/4a4788c1dfc396b1f86355b274cc26b3?s=48"];
            } else if ([serviceID isEqualToString:@"linkedin"]) {
                serviceLabel = @"LinkedIn";
                iconURL = [NSURL URLWithString:@"https://secure.gravatar.com/blavatar/f54db463750940e0e7f7630fe327845e?s=48"];
            } else if ([serviceID isEqualToString:@"path"]) {
                serviceLabel = @"Path";
                iconURL = [NSURL URLWithString:@"https://secure.gravatar.com/blavatar/3a03c8ce5bf1271fb3760bb6e79b02c1?s=48"];
            }
            
            statsItem.label = serviceLabel;
            statsItem.iconURL = iconURL;
            statsItem.value = [self localizedStringForNumber:[service numberForKey:@"followers"]];
            
            [items addObject:statsItem];
        }
        
        if (completionHandler) {
            // More not available with publicize
            completionHandler(items, nil, false);
        }
    };
    
    NSDictionary *parameters = @{@"period" : [self stringForPeriodUnit:unit],
                                 @"date"   : [self siteLocalStringForDate:date]};
    
    AFHTTPRequestOperation *operation = [self requestOperationForURLString:[self urlForPublicize]
                                                                parameters:parameters
                                                                   success:handler
                                                                   failure:[self failureForFailureCompletionHandler:failureHandler]];
    
    return operation;
}


#pragma mark - Private convenience methods for building requests

- (AFHTTPRequestOperation *)requestOperationForURLString:(NSString *)url
                                              parameters:(NSDictionary *)parameters
                                                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"GET"
                                                                    URLString:url
                                                                   parameters:parameters
                                                                        error:nil];
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:success
                                                                              failure:failure];
    
    return operation;
}


- (void(^)(AFHTTPRequestOperation *operation, NSError *error))failureForFailureCompletionHandler:(void (^)(NSError *error))failureHandler
{
    return ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        DDLogError(@"Error with today summary stats: %@", error);
        
        if (failureHandler) {
            failureHandler(error);
        }
    };
}


// TODO :: These could probably go into the operation methods since it's not really helpful any more
#pragma mark - Private methods for URL convenience


- (NSString *)urlForSummary
{
    return [NSString stringWithFormat:@"%@/summary/", self.statsPathPrefix];
}


- (NSString *)urlForVisits
{
    return [NSString stringWithFormat:@"%@/visits/", self.statsPathPrefix];
}


- (NSString *)urlForClicks
{
    return [NSString stringWithFormat:@"%@/clicks", self.statsPathPrefix];
}


- (NSString *)urlForCountryViews
{
    return [NSString stringWithFormat:@"%@/country-views", self.statsPathPrefix];
}


- (NSString *)urlForReferrers
{
    return [NSString stringWithFormat:@"%@/referrers/", self.statsPathPrefix];
}


- (NSString *)urlForPosts
{
    return [NSString stringWithFormat:@"%@/posts/", self.sitesPathPrefix];
}


- (NSString *)urlForTopPosts
{
    return [NSString stringWithFormat:@"%@/top-posts/", self.statsPathPrefix];
}

- (NSString *)urlForVideos
{
    return [NSString stringWithFormat:@"%@/video-plays/", self.statsPathPrefix];
}


- (NSString *)urlForComments
{
    return [NSString stringWithFormat:@"%@/comments/", self.statsPathPrefix];
}


- (NSString *)urlForTagsCategories
{
    return [NSString stringWithFormat:@"%@/tags/", self.statsPathPrefix];
}


- (NSString *)urlForFollowers
{
    return [NSString stringWithFormat:@"%@/followers/", self.statsPathPrefix];
}


- (NSString *)urlForPublicize
{
    return [NSString stringWithFormat:@"%@/publicize/", self.statsPathPrefix];
}


#pragma mark - Private convenience methods for data conversion


- (NSDate *)deviceLocalDateForString:(NSString *)dateString withPeriodUnit:(StatsPeriodUnit)unit
{
    switch (unit) {
        case StatsPeriodUnitDay:
        {
            self.deviceDateFormatter.dateFormat = @"yyyy-MM-dd";
            break;
        }
        case StatsPeriodUnitWeek:
        {
            // Assumes format: yyyyWxxWxx first xx is month, second xx is first day of that week
            self.deviceDateFormatter.dateFormat = @"yyyy'W'MM'W'dd";
            break;
        }
        case StatsPeriodUnitMonth:
        {
            self.deviceDateFormatter.dateFormat = @"yyyy-MM-dd";
            break;
        }
        case StatsPeriodUnitYear:
            
            break;
    }
    
    NSDate *localDate = [self.deviceDateFormatter dateFromString:dateString];
    
    return localDate;
}

- (NSString *)siteLocalStringForDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd";
    formatter.timeZone = self.siteTimeZone;
    
    NSString *todayString = [formatter stringFromDate:date];

    return todayString;
}

- (StatsPeriodUnit)periodUnitForString:(NSString *)unitString
{
    if ([unitString isEqualToString:@"day"]) {
        return StatsPeriodUnitDay;
    } else if ([unitString isEqualToString:@"week"]) {
        return StatsPeriodUnitWeek;
    } else if ([unitString isEqualToString:@"month"]) {
        return StatsPeriodUnitMonth;
    } else if ([unitString isEqualToString:@"year"]) {
        return StatsPeriodUnitYear;
    }
    
    return StatsPeriodUnitDay;
}

- (NSString *)stringForPeriodUnit:(StatsPeriodUnit)unit
{
    switch (unit) {
        case StatsPeriodUnitDay:
            return @"day";
        case StatsPeriodUnitWeek:
            return @"week";
        case StatsPeriodUnitMonth:
            return @"month";
        case StatsPeriodUnitYear:
            return @"year";
    }
    
    return @"";
}

- (NSString *)nicePointNameForDate:(NSDate *)date forStatsPeriodUnit:(StatsPeriodUnit)unit {
    if (!date) {
        return @"";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    
    switch (unit) {
        case StatsPeriodUnitDay:
            dateFormatter.dateFormat = @"LLL dd";
            break;
        case StatsPeriodUnitWeek:
            dateFormatter.dateFormat = @"LLL dd";
            break;
        case StatsPeriodUnitMonth:
            dateFormatter.dateFormat = @"LLL";
            break;
        case StatsPeriodUnitYear:
            dateFormatter.dateFormat = @"yyyy";
            break;
    }
    
    NSString *niceName = [dateFormatter stringFromDate:date] ?: @"";

    return niceName;
}

- (NSString *)localizedStringForNumber:(NSNumber *)number
{
    if (!number) {
        return nil;
    }
    
    self.deviceNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.deviceNumberFormatter.maximumFractionDigits = 0;
    
    NSString *formattedNumber = [self.deviceNumberFormatter stringFromNumber:number];
    
    return formattedNumber;
}

@end

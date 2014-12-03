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
    
    [self.remote batchFetchStatsForDates:dates
                                 andUnit:unit
             withVisitsCompletionHandler:^(StatsVisits *visits)
    {
        visitsResult = visits;
        
        if (visitsCompletion) {
            visitsCompletion(visits);
        }
    }
                  postsCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        postsResult.items = items;
        postsResult.titlePrimary = NSLocalizedString(@"Posts & Pages", @"Title for stats section for Posts & Pages");
        
        if (postsCompletion) {
            postsCompletion(postsResult);
        }
    }
              referrersCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        referrersResult.items = items;
        
        if (referrersCompletion) {
            referrersCompletion(referrersResult);
        }
    }
                 clicksCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        clicksResult.items = items;
        
        if (clicksCompletion) {
            clicksCompletion(clicksResult);
        }
    }
                countryCompletionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        countriesResult.items = items;
        
        if (countryCompletion) {
            countryCompletion(countriesResult);
        }
    }
                  videosCompetionHandler:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        videosResult.items = items;
        
        if (videosCompletion) {
            videosCompletion(videosResult);
        }
    }
                      commentsCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        commentsResult.items = items;
        
        if (commentsCompletion) {
            commentsCompletion(commentsResult);
        }
    }
                tagsCategoriesCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        tagsCategoriesResult.items = items;
        
        if (tagsCategoriesCompletion) {
            tagsCategoriesCompletion(tagsCategoriesResult);
        }
    }
                     followersCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
    {
        followersResult.items = items;
        
        if (followersCompletion) {
            followersCompletion(followersResult);
        }
    }
                     publicizeCompletion:^(NSArray *items, NSNumber *totalViews, NSNumber *otherViews)
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

@end
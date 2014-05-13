#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import "WordPressComApi.h"

@interface WPStatsService ()

@property (nonatomic, strong) NSNumber *siteId;
@property (nonatomic, strong) NSString *oauth2Token;

@end

@implementation WPStatsService
{

}

- (instancetype)initWithSiteId:(NSNumber *)siteId andOAuth2Token:(NSString *)oauth2Token
{
    self = [super init];
    if (self) {
        _siteId = siteId;
        _oauth2Token = oauth2Token;
    }

    return self;
}

- (void)retrieveStatsWithCompletionHandler:(StatsCompletion)completion failureHandler:(void (^)(NSError *error))failureHandler
{
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

    [self.remote fetchStatsForTodayDate:today
                       andYesterdayDate:yesterday
                  withCompletionHandler:completion
                         failureHandler:failure];
}

- (WPStatsServiceRemote *)remote
{
    if (!_remote) {
        WordPressComApi *api = [[WordPressComApi alloc] initWithOAuthToken:self.oauth2Token];
        _remote = [[WPStatsServiceRemote alloc] initWithRemoteApi:api
                                                        andSiteId:self.siteId];
    }

    return _remote;
}

@end
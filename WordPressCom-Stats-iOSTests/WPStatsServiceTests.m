#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import <OCMock.h>
#import "StatsItem.h"

@interface WPStatsServiceRemoteMock : WPStatsServiceRemote

@end

@interface WPStatsServiceTests : XCTestCase

@property (nonatomic, strong) WPStatsService *subject;

@end

@implementation WPStatsServiceTests

- (void)setUp {
    [super setUp];
    
    self.subject = [[WPStatsService alloc] initWithSiteId:@123456 siteTimeZone:[NSTimeZone systemTimeZone] andOAuth2Token:@"token"];
}

- (void)tearDown {
    [super tearDown];

    self.subject = nil;
}

- (void)testCompletionHandlers {
    WPStatsServiceRemoteMock *remoteMock = [WPStatsServiceRemoteMock new];
    self.subject.remote = remoteMock;

    XCTestExpectation *visitsExpectation = [self expectationWithDescription:@"visitsExpectation"];
    XCTestExpectation *postsExpectation = [self expectationWithDescription:@"postsExpectation"];
    XCTestExpectation *referrersExpectation = [self expectationWithDescription:@"referrersExpectation"];
    XCTestExpectation *clicksExpectation = [self expectationWithDescription:@"clicksExpectation"];
    XCTestExpectation *countryExpectation = [self expectationWithDescription:@"countryExpectation"];
    XCTestExpectation *videosExpectation = [self expectationWithDescription:@"videosExpectation"];
    XCTestExpectation *commentsAuthorExpectation = [self expectationWithDescription:@"commentsAuthorExpectation"];
    XCTestExpectation *commentsPostsExpectation = [self expectationWithDescription:@"commentsPostsExpectation"];
    XCTestExpectation *tagsExpectation = [self expectationWithDescription:@"tagsExpectation"];
    XCTestExpectation *followersDotComExpectation = [self expectationWithDescription:@"followersDotComExpectation"];
    XCTestExpectation *followersEmailExpectation = [self expectationWithDescription:@"followersEmailExpectation"];
    XCTestExpectation *publicizeExpectation = [self expectationWithDescription:@"publicizeExpectation"];
    XCTestExpectation *overallExpectation = [self expectationWithDescription:@"overallExpectation"];
    
    [self.subject retrieveAllStatsForDates:@[[NSDate date]]
                                   andUnit:StatsPeriodUnitDay
               withVisitsCompletionHandler:^(StatsVisits *visits) {
                   [visitsExpectation fulfill];
               }
                    postsCompletionHandler:^(StatsGroup *group) {
                        [postsExpectation fulfill];
                    }
                referrersCompletionHandler:^(StatsGroup *group) {
                    [referrersExpectation fulfill];
                }
                   clicksCompletionHandler:^(StatsGroup *group) {
                       [clicksExpectation fulfill];
                }
                  countryCompletionHandler:^(StatsGroup *group) {
                      [countryExpectation fulfill];
                }
                   videosCompletionHandler:^(StatsGroup *group) {
                       [videosExpectation fulfill];
                }
           commentsAuthorCompletionHandler:^(StatsGroup *group) {
               [commentsAuthorExpectation fulfill];
           }
            commentsPostsCompletionHandler:^(StatsGroup *group) {
                [commentsPostsExpectation fulfill];
            }
           tagsCategoriesCompletionHandler:^(StatsGroup *group) {
               [tagsExpectation fulfill];
           }
          followersDotComCompletionHandler:^(StatsGroup *group) {
              [followersDotComExpectation fulfill];
          }
           followersEmailCompletionHandler:^(StatsGroup *group) {
               [followersEmailExpectation fulfill];
           }
                publicizeCompletionHandler:^(StatsGroup *group) {
                    [publicizeExpectation fulfill];
                }
               andOverallCompletionHandler:^{
                   [overallExpectation fulfill];
               }
                     overallFailureHandler:^(NSError *error) {
                         XCTFail(@"Failure is not an option.");
                     }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDateSanitizationDay
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 12;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                               periodUnit:StatsPeriodUnitDay
                             expectedYear:2014
                                    month:12
                                      day:1];
}


- (void)testDateSanitizationWeek
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 12;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitWeek
                               expectedYear:2014
                                      month:12
                                        day:6];
}


- (void)testDateSanitizationWeekCrossesYear
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 12;
    dateComponents.day = 30;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitWeek
                               expectedYear:2015
                                      month:1
                                        day:3];
}


- (void)testDateSanitizationMonth
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 12;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitMonth
                               expectedYear:2014
                                      month:12
                                        day:31];
}


- (void)testDateSanitizationMonthLeapYear
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2016;
    dateComponents.month = 2;
    dateComponents.day = 13;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitMonth
                               expectedYear:2016
                                      month:2
                                        day:29];
}


- (void)testDateSanitizationYear
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 2;
    dateComponents.day = 13;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitYear
                               expectedYear:2014
                                      month:12
                                        day:31];
}


- (void)testDateSanitizationYearFirstOfYear
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 1;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitYear
                               expectedYear:2014
                                      month:12
                                        day:31];
}


- (void)testDateSanitizationYearLastOfYear
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2014;
    dateComponents.month = 12;
    dateComponents.day = 31;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    [self verifyDateSantizationWithBaseDate:date
                                 periodUnit:StatsPeriodUnitYear
                               expectedYear:2014
                                      month:12
                                        day:31];
}


#pragma mark - Private test helper methods

- (void)verifyDateSantizationWithBaseDate:(NSDate *)baseDate periodUnit:(StatsPeriodUnit)unit expectedYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    WPStatsServiceRemote *remote = OCMClassMock([WPStatsServiceRemote class]);
    
    id dateCheckBlock = [OCMArg checkWithBlock:^BOOL(id obj) {
        NSDate *date = obj[0];
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
        BOOL isOkay = dateComponents.year == year && dateComponents.month == month && dateComponents.day == day;
        
        return isOkay;
    }];
    
    OCMExpect([remote batchFetchStatsForDates:dateCheckBlock
                                      andUnit:unit
                  withVisitsCompletionHandler:[OCMArg any]
                       postsCompletionHandler:[OCMArg any]
                   referrersCompletionHandler:[OCMArg any]
                      clicksCompletionHandler:[OCMArg any]
                     countryCompletionHandler:[OCMArg any]
                      videosCompletionHandler:[OCMArg any]
                    commentsCompletionHandler:[OCMArg any]
              tagsCategoriesCompletionHandler:[OCMArg any]
             followersDotComCompletionHandler:[OCMArg any]
              followersEmailCompletionHandler:[OCMArg any]
                   publicizeCompletionHandler:[OCMArg any]
                  andOverallCompletionHandler:[OCMArg any]
                        overallFailureHandler:[OCMArg any]]);
    
    self.subject.remote = remote;
    
    [self.subject retrieveAllStatsForDates:@[baseDate]
                                   andUnit:unit
               withVisitsCompletionHandler:nil
                    postsCompletionHandler:nil
                referrersCompletionHandler:nil
                   clicksCompletionHandler:nil
                  countryCompletionHandler:nil
                   videosCompletionHandler:nil
           commentsAuthorCompletionHandler:nil
            commentsPostsCompletionHandler:nil
           tagsCategoriesCompletionHandler:nil
          followersDotComCompletionHandler:nil
           followersEmailCompletionHandler:nil
                publicizeCompletionHandler:nil
               andOverallCompletionHandler:^{
                   // Don't do anything
               }
                     overallFailureHandler:nil];
    
    OCMVerifyAll((id)remote);
}

@end


@implementation WPStatsServiceRemoteMock

- (void)batchFetchStatsForDates:(NSArray *)dates
                        andUnit:(StatsPeriodUnit)unit
    withVisitsCompletionHandler:(StatsRemoteVisitsCompletion)visitsCompletion
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
          overallFailureHandler:(void (^)(NSError *))failureHandler
{
    NSInteger count = dates.count;
    for (NSInteger x = 0; x < count; ++x) {
        if (visitsCompletion) {
            visitsCompletion([StatsVisits new]);
        }
        if (postsCompletion) {
            postsCompletion(@[[StatsItem new]], nil, nil);
        }
        if (referrersCompletion) {
            referrersCompletion(@[[StatsItem new]], nil, nil);
        }
        if (clicksCompletion) {
            clicksCompletion(@[[StatsItem new]], nil, nil);
        }
        if (countryCompletion) {
            countryCompletion(@[[StatsItem new]], nil, nil);
        }
        if (videosCompletion) {
            videosCompletion(@[[StatsItem new]], nil, nil);
        }
        if (commentsCompletion) {
            commentsCompletion(@[[StatsItem new]], nil, nil);
        }
        if (tagsCategoriesCompletion) {
            tagsCategoriesCompletion(@[[StatsItem new]], nil, nil);
        }
        if (followersDotComCompletion) {
            followersDotComCompletion(@[[StatsItem new]], nil, nil);
        }
        if (followersEmailCompletion) {
            followersEmailCompletion(@[[StatsItem new]], nil, nil);
        }
        if (publicizeCompletion) {
            publicizeCompletion(@[[StatsItem new]], nil, nil);
        }
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

@end

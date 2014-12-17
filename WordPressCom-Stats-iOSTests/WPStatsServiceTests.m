#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "WPStatsService.h"
#import "WPStatsServiceRemote.h"
#import <OCMock.h>

@interface WPStatsServiceTests : XCTestCase

@property (nonatomic, strong) WPStatsService *subject;
@property (nonatomic, strong) WPStatsServiceRemote *remoteMock;

@end

@implementation WPStatsServiceTests

- (void)setUp {
    [super setUp];
    
    self.subject = [[WPStatsService alloc] initWithSiteId:@123456 siteTimeZone:[NSTimeZone systemTimeZone] andOAuth2Token:@"token"];
    
    WPStatsServiceRemote *remoteMock = OCMClassMock([WPStatsServiceRemote class]);
    self.remoteMock = remoteMock;
    self.subject.remote = remoteMock;
}

- (void)tearDown {
    [super tearDown];
    
    self.remoteMock = nil;
    self.subject = nil;
}

- (void)testExample {
    XCTAssert(YES, @"Pass");
}

@end

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StatsGroup.h"
#import "StatsItem.h"

@interface StatsGroupTests : XCTestCase

@end

@implementation StatsGroupTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCollapsedIsDefault
{
    StatsGroup *group = [StatsGroup new];
    XCTAssertFalse(group.isExpanded);
}

- (void)testNoItems
{
    StatsGroup *group = [StatsGroup new];
    
    XCTAssertEqual(0, group.numberOfRows);
}

- (void)testOneItemNoChildren
{
    StatsGroup *group = [StatsGroup new];
    StatsItem *item = [StatsItem new];
    group.items = @[item];
    
    XCTAssertEqual(1, group.numberOfRows);
}

- (void)testTwoItemNoChildren
{
    StatsGroup *group = [StatsGroup new];
    StatsItem *item1 = [StatsItem new];
    StatsItem *item2 = [StatsItem new];
    group.items = @[item1, item2];
    
    XCTAssertEqual(2, group.numberOfRows);
}

@end

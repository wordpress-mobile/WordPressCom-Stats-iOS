#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StatsItem+View.h"

@interface StatsItem_ViewTests : XCTestCase

@end

@implementation StatsItem_ViewTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCollapsedIsDefault
{
    StatsItem *item = [StatsItem new];
    XCTAssertFalse(item.isExpanded);
}

- (void)testNoChildrenCollapsed {
    StatsItem *item = [StatsItem new];
    item.expanded = NO;
    
    XCTAssertEqual(1, item.numberOfRows);
}

- (void)testNoChildrenExpanded {
    StatsItem *item = [StatsItem new];
    item.expanded = YES;
    
    XCTAssertEqual(1, item.numberOfRows);
}

- (void)testOneChildCollapsed {
    StatsItem *item = [StatsItem new];
    item.expanded = NO;
    [item addChildStatsItem:[StatsItem new]];
    
    XCTAssertEqual(1, item.numberOfRows);
}

- (void)testOneChildExpanded {
    StatsItem *item = [StatsItem new];
    item.expanded = YES;
    [item addChildStatsItem:[StatsItem new]];
    
    XCTAssertEqual(2, item.numberOfRows);
}

- (void)testDepthOneItem
{
    StatsItem *item = [StatsItem new];
    XCTAssertEqual(1, item.depth);
}

- (void)testDepthOneChildItem
{
    StatsItem *item = [StatsItem new];
    StatsItem *itemChild = [StatsItem new];
    
    [item addChildStatsItem:itemChild];
    
    XCTAssertEqual(1, item.depth);
    XCTAssertEqual(2, itemChild.depth);
}


@end

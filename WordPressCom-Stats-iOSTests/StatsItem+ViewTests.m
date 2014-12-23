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
    item.children = @[[StatsItem new]];
    
    XCTAssertEqual(1, item.numberOfRows);
}

- (void)testOneChildExpanded {
    StatsItem *item = [StatsItem new];
    item.expanded = YES;
    item.children = @[[StatsItem new]];
    
    XCTAssertEqual(2, item.numberOfRows);
}



@end

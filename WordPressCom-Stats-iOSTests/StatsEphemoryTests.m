#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StatsEphemory.h"

@interface StatsEphemoryTests : XCTestCase

@property (nonatomic, strong) StatsEphemory *subject;

@end

@implementation StatsEphemoryTests

- (void)setUp
{
    [super setUp];

    self.subject = [[StatsEphemory alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    self.subject = nil;
}

- (void)testObjectForKeyNoMatch
{
    XCTAssertNil([self.subject objectForKey:@"nosuchmatch"]);
}

- (void)testObjectForKeyNil
{
    XCTAssertThrows([self.subject objectForKey:nil]);
}

- (void)testSetObjectValid
{
    [self.subject setObject:@"Test" forKey:@"TestKey"];
    
    XCTAssertEqual(@"Test", [self.subject objectForKey:@"TestKey"]);
}

- (void)testSetObjectNilObject
{
    XCTAssertThrows([self.subject setObject:nil forKey:@"TestKey"]);
}

- (void)testRemoveAllObjectsNoObjects
{
    XCTAssertNoThrow([self.subject removeAllObjects]);
}

- (void)testRemoveAllObjectsOneObject
{
    [self.subject setObject:@"Test" forKey:@"TestKey"];
    
    XCTAssertNoThrow([self.subject removeAllObjects]);
    XCTAssertNil([self.subject objectForKey:@"TestKey"]);
}

- (void)testRemoveObjectNonExistent
{
    XCTAssertNoThrow([self.subject removeObjectForKey:@"TestKey"]);
}

- (void)testRemoveObjectExists
{
    [self.subject setObject:@"Test" forKey:@"TestKey"];
    
    XCTAssertNoThrow([self.subject removeObjectForKey:@"TestKey"]);
    XCTAssertNil([self.subject objectForKey:@"TestKey"]);
}

- (void)testObjectForKeySuperShortExpiry
{
    self.subject = [[StatsEphemory alloc] initWithExpiryInterval:-1];
    
    [self.subject setObject:@"Test" forKey:@"TestKey"];
    XCTAssertNil([self.subject objectForKey:@"TestKey"]);
}

@end

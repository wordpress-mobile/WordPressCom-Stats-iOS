import UIKit
import XCTest

class WPStatsViewsVisitorsTests: XCTestCase {
    var viewsVisitors: WPStatsViewsVisitors?

    override func setUp() {
        super.setUp()
        
        viewsVisitors = WPStatsViewsVisitors()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNicePointNamesEmptyText() {
        let result = viewsVisitors!.nicePointNames("", forUnit: WPStatsViewsVisitorsUnit.StatsViewsVisitorsUnitDay)
        
        XCTAssertNotNil(result, "Result shouldn't be nil")
        XCTAssertTrue(result.count == 0, "Should have no entry")
    }
    
    func testNicePointNamesNilText() {
        let result = viewsVisitors!.nicePointNames(nil, forUnit: WPStatsViewsVisitorsUnit.StatsViewsVisitorsUnitDay)
        
        XCTAssertNotNil(result, "Result shouldn't be nil")
        XCTAssertTrue(result.count == 0, "Should have no entry")
    }
    
    func testNicePointNamesBlankText() {
        let result = viewsVisitors!.nicePointNames(" ", forUnit: WPStatsViewsVisitorsUnit.StatsViewsVisitorsUnitDay)
        
        XCTAssertNotNil(result, "Result shouldn't be nil")
        XCTAssertTrue(result.count == 1, "Should have one entry")
    }
    
    func testNicePointNamesNonDateTextDay() {
        let result = viewsVisitors!.nicePointNames("This isn't a date", forUnit: WPStatsViewsVisitorsUnit.StatsViewsVisitorsUnitDay)
        
        XCTAssertNotNil(result, "Result shouldn't be nil")
        XCTAssertTrue(result.count == 1, "Should have one entry")
    }
    
    func testNicePointNamesNonDateTextDayMonth() {
        let result = viewsVisitors!.nicePointNames("This isn't a date", forUnit: WPStatsViewsVisitorsUnit.StatsViewsVisitorsUnitMonth)
        
        XCTAssertNotNil(result, "Result shouldn't be nil")
        XCTAssertTrue(result.count == 1, "Should have one entry")
    }
    
    func testNicePointNamesNonDateTextWeek() {
        let result = viewsVisitors!.nicePointNames("This isn't a date", forUnit: WPStatsViewsVisitorsUnit.StatsViewsVisitorsUnitWeek)
        
        XCTAssertNotNil(result, "Result shouldn't be nil")
        XCTAssertTrue(result.count == 1, "Should have one entry")
    }
}

import UIKit
import XCTest
import WordPressCom_Stats_iOS

class StatsServiceRemoteTests: XCTestCase {
    var statsServiceRemote: StatsServiceRemote!
    
    override func setUp() {
        super.setUp()
        
        statsServiceRemote = StatsServiceRemote(oauth2Token: "", siteId: 1234, siteTimeZone: NSTimeZone(name: "America/Chicago")!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}

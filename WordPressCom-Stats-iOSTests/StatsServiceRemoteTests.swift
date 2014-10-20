import UIKit
import XCTest
import WordPressCom_Stats_iOS

class StatsServiceRemoteTests: XCTestCase {
    var statsServiceRemote: StatsServiceRemote!
    
    override func setUp() {
        super.setUp()
        
        statsServiceRemote = StatsServiceRemote(oauth2Token: "8FQL!KdgYxEwtGOUB(F6nnM74Abg@m0EaLq1XeWnL8ftg9!Hu3UA&E%DHilWSMgH", siteId: 54117, siteTimeZone: NSTimeZone(name: "America/Chicago")!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSummary() {
        let expection = self.expectationWithDescription("summaryFetched")
        
        statsServiceRemote.fetchStatsSummary { (summary, error) -> () in
            expection.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(2.0, handler: nil)
        
        XCTAssert(true, "Pass")
    }

}

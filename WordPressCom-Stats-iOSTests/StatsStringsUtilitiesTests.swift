import XCTest
import WordPressComStatsiOS

class StatsStringsUtilitiesTests: XCTestCase {
    var subject: StatsStringUtilities!
    
    override func setUp() {
        super.setUp()

        subject = StatsStringUtilities()
    }
    
    override func tearDown() {
        super.tearDown()
        
        subject = nil
    }
    
    func testSanitizePostTitleEmptyString() {
        let result = subject.sanitizePostTitle("")
        
        XCTAssertTrue(result == "")
    }
    
    func testSanitizePostTitleWhitespaceString() {
        let result = subject.sanitizePostTitle(" ")
        
        XCTAssertTrue(result == "")
    }
    
    func testSanitizePostTitleNonCharacterString() {
        let result = subject.sanitizePostTitle("_")
        
        XCTAssertTrue(result == "_")
    }
    
    func testSanitizePostTitleHTMLEntityString() {
        let result = subject.sanitizePostTitle("&amp;")
        
        XCTAssertTrue(result == "&")
    }
    
    func testSanitizePostTitleComplexHTMLEntityString() {
        let result = subject.sanitizePostTitle("This &#8220;has&#8221; special &amp; characters")
        
        XCTAssertTrue(result == "This “has” special & characters")
    }
}

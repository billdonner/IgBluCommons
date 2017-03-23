import XCTest
@testable import IgBluCommons

class IgBluCommonsTests: XCTestCase {
    func testExample() {
    let t = 
        XCTAssertEqual(IgBluCommons().text, "Hello, World!")
    }


    static var allTests : [(String, (IgBluCommonsTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}

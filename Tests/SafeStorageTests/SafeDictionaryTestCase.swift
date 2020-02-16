import XCTest
@testable import SafeStorage

final class SafeDictionaryTestCase: XCTestCase {
    private var dict: SafeDictionary<String, String>!
    
    override func setUp() {
        dict = SafeDictionary<String, String>()
    }
    
    func testNoKey() {
        XCTAssertNil(dict["foo"])
    }
    
    func testGetSetKey() {
        dict["foo"] = "bar"
        XCTAssertEqual(dict["foo"], "bar")
    }
    
    func testRemoveKey() {
        testGetSetKey()
        dict["foo"] = nil
        testNoKey()
    }

    static var allTests = [
        ("testNoKey", testNoKey),
        ("testSetKey", testGetSetKey),
        ("testRemoveKey", testRemoveKey),
    ]
}

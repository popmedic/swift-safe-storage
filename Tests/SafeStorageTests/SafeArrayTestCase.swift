import XCTest
@testable import SafeStorage

final class SafeArrayTestCase: XCTestCase {
    private var array: SafeArray<String>!
    
    override func setUp() {
        array = SafeArray<String>()
    }
    
    func testAdd() {
        array.add("Value")
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], "Value")
    }
    
    func testRemoveValueNotExist() {
        XCTAssertNil(array.remove("Value") { $0 == $1 })
    }
    
    func testRemoveOutOfIndex() {
        testAdd()
        array.remove(100)
        XCTAssertEqual(array.count, 1)
    }

    func testRemoveValue() {
        testAdd()
        XCTAssertEqual(array.remove("Value") { $0 == $1 }, 0)
    }
    
    func testUpsertValueExist() {
        testAdd()
        array.upsert("Value") { $0 == $1 }
        XCTAssertEqual(array.count, 1)
    }
    
    func testUpsertValueNotExist() {
        testAdd()
        array.upsert("Value2") { $0 == $1 }
        XCTAssertEqual(array.count, 2)
    }
    
    static var allTests = [
        ("testAdd", testAdd),
        ("testRemoveValueNotExist", testRemoveValueNotExist),
        ("testRemoveOutOfIndex", testRemoveOutOfIndex),
        ("testRemoveValue", testRemoveValue),
        ("testUpsertValueExist", testUpsertValueExist),
        ("testUpsertValueNotExist", testUpsertValueNotExist)
    ]
}

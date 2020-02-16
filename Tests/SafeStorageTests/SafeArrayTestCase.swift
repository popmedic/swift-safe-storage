import XCTest
@testable import SafeStorage

final class SafeArrayTestCase: XCTestCase {
    private var array: SafeArray<String>!
    
    override func setUp() {
        array = SafeArray<String>()
    }
    
    func testAdd() {
        array.append("Value")
        XCTAssertEqual(array.count, 1)
        XCTAssertEqual(array[0], "Value")
    }
    
    func testInsert() {
        array.insert("Value1", at: 0)
        array.insert("Value0", at: 0)
        array.insert("Value2", at: 100)
        XCTAssertEqual(array.count, 3)
        XCTAssertEqual(array[0], "Value0")
        XCTAssertEqual(array[1], "Value1")
        XCTAssertEqual(array[2], "Value2")
    }
    
    func testRemoveByIndexNotExist() {
        array.remove(1)
        XCTAssertEqual(array.count, 0)
    }
    
    func testRemoveByIndex() {
        testAdd()
        array.remove(0)
        XCTAssertEqual(array.count, 0)
    }
    
    func testRemoveValueNotExist() {
        array.remove("Value") { $0 == $1 }
        XCTAssertEqual(array.count, 0)
    }
    
    func testRemoveOutOfIndex() {
        testAdd()
        array.remove(100)
        XCTAssertEqual(array.count, 1)
    }

    func testRemoveValue() {
        testAdd()
        array.remove("Value") { $0 == $1 }
        XCTAssertEqual(array.count, 0)
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
    
    func testUpsertThreaded() {
        threadIt { index in
            self.array.upsert("Value") { $0 == $1 }
            XCTAssertEqual(self.array.find("Value") { $0 == $1 }, 0)
        }
        XCTAssertEqual(array.count, 1)
    }
    
    func testAddFindGetRemoveThreaded() {
        threadIt { index in
            self.array.append("\(index)")
            XCTAssertNotNil(self.array.find("\(index)") { $0 == $1 })
            XCTAssertNotNil(self.array.get(index))
        }
        XCTAssertEqual(self.array.count, 100)
        threadIt { index in
            let queueA = DispatchQueue(label: "A")
            let queueB = DispatchQueue(label: "B")
            queueA.async { XCTAssertNotNil(self.array.find("\(index)") { $0 == $1 }) }
            queueB.async { XCTAssertNotNil(self.array.get(index)) }
        }
        threadIt { index in
            self.array.remove("\(index)") { $0 == $1 }
        }
        XCTAssertEqual(array.count, 0)
    }
    
    func testInsertFindGetRemoveThreaded() {
        threadIt { index in
            self.array.insert("\(index)", at: index)
            XCTAssertNotNil(self.array.find("\(index)") { $0 == $1 })
            XCTAssertNotNil(self.array.get(index))
        }
        XCTAssertEqual(self.array.count, 100)
        threadIt { index in
            let queueA = DispatchQueue(label: "A")
            let queueB = DispatchQueue(label: "B")
            queueA.async { XCTAssertNotNil(self.array.find("\(index)") { $0 == $1 }) }
            queueB.async { XCTAssertNotNil(self.array.get(index)) }
        }
        threadIt { index in
            self.array.remove("\(index)") { $0 == $1 }
        }
        XCTAssertEqual(array.count, 0)
    }
    
    private func threadIt(times: Int = 100, threadBlock: @escaping (_ index: Int) -> Void) {
        var dispatchArray = [DispatchQueue]()
        let dispatchGroup = DispatchGroup()
        for i in 0..<times {
            let dispatchQueue = DispatchQueue(label: "\(i)")
            dispatchArray.append(dispatchQueue)
            dispatchGroup.enter()
            dispatchQueue.async {
                threadBlock(i)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
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

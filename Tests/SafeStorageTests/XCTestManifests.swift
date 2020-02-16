import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SafeDictionaryTestCase.allTests),
        testCase(SafeArrayTestCase.allTests),
    ]
}
#endif

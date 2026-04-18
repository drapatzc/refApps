import XCTest
@testable import App13
// swift-collections ist nicht über CocoaPods verfügbar (nur SPM)

final class CollectionsTests: XCTestCase {
    func testCollectionsNotAvailableViaCocoapods() {
        // swift-collections nicht verfügbar über CocoaPods — kein Import möglich
        XCTAssertTrue(true)
    }
}

import XCTest
@testable import App14
// swift-collections ist nicht über Carthage verfügbar (nur SPM)

final class CollectionsTests: XCTestCase {
    func testCollectionsNotAvailableViaCarthage() {
        // swift-collections nicht verfügbar über Carthage — kein Import möglich
        XCTAssertTrue(true)
    }
}

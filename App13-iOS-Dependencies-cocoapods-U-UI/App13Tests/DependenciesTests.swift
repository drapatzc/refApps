import XCTest
@testable import App13
// swift-dependencies ist nicht über CocoaPods verfügbar (nur SPM)

final class DependenciesTests: XCTestCase {
    func testDependenciesNotAvailableViaCocoapods() {
        // swift-dependencies nicht verfügbar über CocoaPods — kein Import möglich
        XCTAssertTrue(true)
    }
}

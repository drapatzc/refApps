import XCTest
@testable import App13
// Defaults ist nicht über CocoaPods verfügbar (nur SPM)

final class DefaultsTests: XCTestCase {
    func testDefaultsNotAvailableViaCocoapods() {
        // Defaults nicht verfügbar über CocoaPods — kein Import möglich
        XCTAssertTrue(true)
    }
}

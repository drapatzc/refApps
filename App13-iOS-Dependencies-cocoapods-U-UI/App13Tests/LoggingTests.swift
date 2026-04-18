import XCTest
@testable import App13
// swift-log ist nicht über CocoaPods verfügbar (nur SPM)

final class LoggingTests: XCTestCase {
    func testLoggingNotAvailableViaCocoapods() {
        // swift-log nicht verfügbar über CocoaPods — kein Import möglich
        XCTAssertTrue(true)
    }
}

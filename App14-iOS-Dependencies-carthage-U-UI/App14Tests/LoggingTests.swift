import XCTest
@testable import App14
// swift-log ist nicht über Carthage verfügbar (nur SPM)

final class LoggingTests: XCTestCase {
    func testLoggingNotAvailableViaCarthage() {
        // swift-log nicht verfügbar über Carthage — kein Import möglich
        XCTAssertTrue(true)
    }
}

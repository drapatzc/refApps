import XCTest
import Logging
@testable import App15

final class LoggingTests: XCTestCase {
    func testLoggerCreation() {
        let logger = Logger(label: "de.drapatz.App15.tests")
        XCTAssertNotNil(logger)
    }
}

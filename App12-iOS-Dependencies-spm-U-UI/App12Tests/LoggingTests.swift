import XCTest
import Logging
@testable import App12

final class LoggingTests: XCTestCase {
    func testLoggerCreation() {
        let logger = Logger(label: "de.drapatz.App12.tests")
        XCTAssertNotNil(logger)
    }
}

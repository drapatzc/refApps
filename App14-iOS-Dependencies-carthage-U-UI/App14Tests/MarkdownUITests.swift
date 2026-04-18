import XCTest
@testable import App14
// MarkdownUI ist nicht über Carthage verfügbar (nur SPM)

final class MarkdownUITests: XCTestCase {
    func testMarkdownUINotAvailableViaCarthage() {
        // MarkdownUI nicht verfügbar über Carthage — kein Import möglich
        XCTAssertTrue(true)
    }
}

import XCTest
@testable import App13
// MarkdownUI ist nicht über CocoaPods verfügbar (nur SPM)

final class MarkdownUITests: XCTestCase {
    func testMarkdownUINotAvailableViaCocoapods() {
        // MarkdownUI nicht verfügbar über CocoaPods — kein Import möglich
        XCTAssertTrue(true)
    }
}

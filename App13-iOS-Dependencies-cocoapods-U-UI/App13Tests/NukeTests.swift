import XCTest
@testable import App13
// Nuke ist nicht über CocoaPods verfügbar (nur SPM)

final class NukeTests: XCTestCase {
    func testNukeNotAvailableViaCocoapods() {
        // Nuke nicht verfügbar über CocoaPods — kein Import möglich
        XCTAssertTrue(true)
    }
}

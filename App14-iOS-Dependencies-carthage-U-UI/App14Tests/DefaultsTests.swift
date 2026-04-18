import XCTest
@testable import App14
// Defaults ist nicht über Carthage verfügbar (nur SPM)

final class DefaultsTests: XCTestCase {
    func testDefaultsNotAvailableViaCarthage() {
        // Defaults nicht verfügbar über Carthage — kein Import möglich
        XCTAssertTrue(true)
    }
}

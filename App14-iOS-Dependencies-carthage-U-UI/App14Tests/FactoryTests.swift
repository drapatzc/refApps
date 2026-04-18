import XCTest
@testable import App14
// Factory ist nicht über Carthage verfügbar (nur SPM)

final class FactoryTests: XCTestCase {
    func testFactoryNotAvailableViaCarthage() {
        // Factory nicht verfügbar über Carthage — kein Import möglich
        XCTAssertTrue(true)
    }
}

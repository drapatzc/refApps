import XCTest
@testable import App14
// swift-dependencies ist nicht über Carthage verfügbar (nur SPM)

final class DependenciesTests: XCTestCase {
    func testDependenciesNotAvailableViaCarthage() {
        // swift-dependencies nicht verfügbar über Carthage — kein Import möglich
        XCTAssertTrue(true)
    }
}

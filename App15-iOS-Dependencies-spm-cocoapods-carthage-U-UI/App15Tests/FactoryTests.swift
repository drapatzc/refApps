import XCTest
import Factory
@testable import App15

final class FactoryTests: XCTestCase {
    func testContainerResolves() {
        let service = Container.shared.greetingService()
        XCTAssertFalse(service.greet().isEmpty)
    }
}

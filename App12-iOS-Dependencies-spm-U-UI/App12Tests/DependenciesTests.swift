import XCTest
import Dependencies
@testable import App12

final class DependenciesTests: XCTestCase {
    func testWithDependenciesWorks() {
        withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 0))
        } operation: {
            XCTAssertNotNil(Date(timeIntervalSince1970: 0))
        }
    }
}

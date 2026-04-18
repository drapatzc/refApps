import XCTest
@testable import App15

final class DefaultsTests: XCTestCase {
    func testDefaultsImportWorks() {
        XCTAssertNotNil(Bundle.main)
    }
}

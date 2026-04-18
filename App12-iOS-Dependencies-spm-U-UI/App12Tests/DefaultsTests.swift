import XCTest
@testable import App12

final class DefaultsTests: XCTestCase {
    func testDefaultsImportWorks() {
        XCTAssertNotNil(Bundle.main)
    }
}

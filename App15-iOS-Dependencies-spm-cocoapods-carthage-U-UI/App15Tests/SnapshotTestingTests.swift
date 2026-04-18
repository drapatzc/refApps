import XCTest
import SnapshotTesting
@testable import App15

final class SnapshotTestingTests: XCTestCase {
    func testSnapshotTestingImportWorks() {
        XCTAssertNotNil(Bundle.main)
    }
}

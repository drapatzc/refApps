import XCTest
import SnapshotTesting
@testable import App12

final class SnapshotTestingTests: XCTestCase {
    func testSnapshotTestingImportWorks() {
        XCTAssertNotNil(Bundle.main)
    }
}

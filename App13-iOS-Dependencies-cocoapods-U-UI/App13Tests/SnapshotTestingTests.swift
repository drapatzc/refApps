import XCTest
import SnapshotTesting
@testable import App13

final class SnapshotTestingTests: XCTestCase {
    func testSnapshotTestingImportWorks() {
        XCTAssertNotNil(Bundle.main)
    }
}

import XCTest
import Collections
@testable import App15

final class CollectionsTests: XCTestCase {
    func testOrderedSetNoDuplicates() {
        var set: OrderedSet<String> = ["Apple", "Banana", "Apple"]
        XCTAssertEqual(set.count, 2)
        set.append("Apple")
        XCTAssertEqual(set.count, 2)
    }
}

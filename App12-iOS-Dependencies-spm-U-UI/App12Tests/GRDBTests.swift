import XCTest
import GRDB
@testable import App12

final class GRDBTests: XCTestCase {
    func testGRDBCanCreateInMemoryDatabase() throws {
        let dbQueue = try DatabaseQueue()
        let result = try dbQueue.read { db in
            try Int.fetchOne(db, sql: "SELECT 1")
        }
        XCTAssertEqual(result, 1)
    }
}

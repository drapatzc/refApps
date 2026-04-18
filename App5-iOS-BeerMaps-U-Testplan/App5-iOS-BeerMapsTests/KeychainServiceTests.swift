import XCTest
@testable import App5_iOS_BeerMaps

final class KeychainServiceTests: XCTestCase {
    var sut: MockKeychainService!

    override func setUp() {
        super.setUp()
        sut = MockKeychainService()
    }

    func testSaveAndLoad() {
        _ = sut.save(key: "testKey", value: "testValue")
        let loaded = sut.load(key: "testKey")
        XCTAssertEqual(loaded, "testValue")
    }

    func testLoadNonexistentKeyReturnsNil() {
        let result = sut.load(key: "nonexistent")
        XCTAssertNil(result)
    }

    func testDeleteRemovesKey() {
        _ = sut.save(key: "testKey", value: "testValue")
        _ = sut.delete(key: "testKey")
        XCTAssertNil(sut.load(key: "testKey"))
    }

    func testSaveOverwritesExistingValue() {
        _ = sut.save(key: "testKey", value: "first")
        _ = sut.save(key: "testKey", value: "second")
        XCTAssertEqual(sut.load(key: "testKey"), "second")
    }

    func testSaveFailureDoesNotStore() {
        sut.shouldSaveFail = true
        let success = sut.save(key: "testKey", value: "value")
        XCTAssertFalse(success)
        XCTAssertNil(sut.load(key: "testKey"))
    }

    func testCallCounts() {
        _ = sut.save(key: "k", value: "v")
        _ = sut.load(key: "k")
        _ = sut.delete(key: "k")
        XCTAssertEqual(sut.saveCallCount, 1)
        XCTAssertEqual(sut.loadCallCount, 1)
        XCTAssertEqual(sut.deleteCallCount, 1)
    }
}

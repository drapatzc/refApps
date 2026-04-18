import XCTest
@testable import App5_iOS_BeerMaps

final class UsernameGeneratorTests: XCTestCase {
    func testGeneratedUsernameEndsWithKohol() {
        for _ in 0..<20 {
            let name = UsernameGenerator.generateUsername()
            XCTAssertTrue(name.hasSuffix("kohol"), "Expected username to end with 'kohol', got: \(name)")
        }
    }

    func testGeneratedUsernameIsNotEmpty() {
        let name = UsernameGenerator.generateUsername()
        XCTAssertFalse(name.isEmpty)
    }

    func testIsValidReturnsFalseForNil() {
        XCTAssertFalse(UsernameGenerator.isValid(nil))
    }

    func testIsValidReturnsFalseForEmpty() {
        XCTAssertFalse(UsernameGenerator.isValid(""))
        XCTAssertFalse(UsernameGenerator.isValid("   "))
    }

    func testIsValidReturnsTrueForValidName() {
        XCTAssertTrue(UsernameGenerator.isValid("Hopfenkohol"))
    }

    func testValidUsernameReturnsStoredIfValid() {
        let mock = MockKeychainService()
        let result = UsernameGenerator.validUsername(from: "Blitzkohol", keychainService: mock)
        XCTAssertEqual(result, "Blitzkohol")
        XCTAssertEqual(mock.saveCallCount, 0)
    }

    func testValidUsernameGeneratesAndSavesIfInvalid() {
        let mock = MockKeychainService()
        let result = UsernameGenerator.validUsername(from: nil, keychainService: mock)
        XCTAssertTrue(result.hasSuffix("kohol"))
        XCTAssertEqual(mock.saveCallCount, 1)
        XCTAssertEqual(mock.storage[KeychainKeys.username], result)
    }

    func testValidUsernameGeneratesAndSavesIfEmpty() {
        let mock = MockKeychainService()
        let result = UsernameGenerator.validUsername(from: "   ", keychainService: mock)
        XCTAssertTrue(result.hasSuffix("kohol"))
        XCTAssertEqual(mock.saveCallCount, 1)
    }

    func testMultipleCallsProduceDifferentNames() {
        var names = Set<String>()
        for _ in 0..<10 {
            names.insert(UsernameGenerator.generateUsername())
        }
        XCTAssertGreaterThan(names.count, 1, "Expected variety in generated names")
    }
}

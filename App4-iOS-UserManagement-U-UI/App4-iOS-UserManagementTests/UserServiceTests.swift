import XCTest
@testable import App4_iOS_UserManagement

@MainActor
final class UserServiceTests: XCTestCase {

    var mockRepository: MockUserRepository!
    var sut: UserService!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = UserService(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository.reset()
        sut = nil
        super.tearDown()
    }

    // MARK: - loadAllUsers

    func test_loadAllUsers_delegatesToRepository() async throws {
        mockRepository.addUser(User.makeTest(firstName: "Test"))
        let users = try await sut.loadAllUsers()
        XCTAssertEqual(mockRepository.fetchAllCallCount, 1)
        XCTAssertEqual(users.count, 1)
    }

    func test_loadAllUsers_repositoryThrows_propagatesError() async {
        mockRepository.shouldThrowOnFetch = true
        do {
            _ = try await sut.loadAllUsers()
            XCTFail("Expected error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - createUser

    func test_createUser_validData_insertsViaRepository() async throws {
        let user = User.makeTest()
        let created = try await sut.createUser(user)
        XCTAssertEqual(mockRepository.insertCallCount, 1)
        XCTAssertGreaterThan(created.id, 0)
    }

    func test_createUser_trimsWhitespace_beforeSaving() async throws {
        let user = User.makeTest(firstName: "  Max  ", lastName: "  Mustermann  ")
        _ = try await sut.createUser(user)
        XCTAssertEqual(mockRepository.lastInsertedUser?.firstName, "Max")
        XCTAssertEqual(mockRepository.lastInsertedUser?.lastName, "Mustermann")
    }

    func test_createUser_invalidData_throwsValidationError() async {
        let user = User.makeTest(firstName: "", lastName: "")
        do {
            _ = try await sut.createUser(user)
            XCTFail("Expected validation error")
        } catch let error as AppError {
            if case .validationFailed(let errors) = error {
                XCTAssertFalse(errors.isEmpty)
            } else {
                XCTFail("Expected validationFailed error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_createUser_invalidEmail_throwsValidationError() async {
        let user = User.makeTest(email: "not-an-email")
        do {
            _ = try await sut.createUser(user)
            XCTFail("Expected validation error")
        } catch let error as AppError {
            if case .validationFailed(let errors) = error {
                let emailErrors = errors.filter { $0.field == .email }
                XCTAssertFalse(emailErrors.isEmpty)
            } else {
                XCTFail("Expected validationFailed error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_createUser_doesNotInsertOnValidationFailure() async {
        let user = User.makeTest(firstName: "")
        _ = try? await sut.createUser(user)
        XCTAssertEqual(mockRepository.insertCallCount, 0)
    }

    // MARK: - updateUser

    func test_updateUser_validData_updatesViaRepository() async throws {
        var user = User.makeTest()
        user.id = 1
        mockRepository.addUser(user)

        user.firstName = "Updated"
        try await sut.updateUser(user)
        XCTAssertEqual(mockRepository.updateCallCount, 1)
    }

    func test_updateUser_invalidData_throwsValidationError() async {
        var user = User.makeTest()
        user.id = 1
        mockRepository.addUser(user)
        user.postalCode = "ABCDE" // Invalid postal code

        do {
            try await sut.updateUser(user)
            XCTFail("Expected validation error")
        } catch let error as AppError {
            if case .validationFailed = error {
                // Erwartet
            } else {
                XCTFail("Expected validationFailed")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    // MARK: - deleteUser

    func test_deleteUser_delegatesToRepository() async throws {
        let user = User.makeTest(id: 1)
        mockRepository.addUser(user)
        try await sut.deleteUser(id: user.id)
        XCTAssertEqual(mockRepository.deleteCallCount, 1)
    }

    // MARK: - validate

    func test_validate_validUser_returnsValid() {
        let user = User.makeTest()
        let result = sut.validate(user)
        XCTAssertTrue(result.isValid)
    }

    func test_validate_invalidUser_returnsInvalid() {
        let user = User.makeTest(firstName: "")
        let result = sut.validate(user)
        XCTAssertFalse(result.isValid)
    }
}

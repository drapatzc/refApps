import XCTest
@testable import App4_iOS_UserManagement

final class UserRepositoryTests: XCTestCase {

    var dbManager: DatabaseManager!
    var sut: UserRepository!

    override func setUp() async throws {
        try await super.setUp()
        // In-memory database for tests
        dbManager = try DatabaseManager(path: ":memory:")
        sut = UserRepository(db: dbManager)
    }

    override func tearDown() async throws {
        sut = nil
        dbManager = nil
        try await super.tearDown()
    }

    // MARK: - Insert

    func test_insert_setsGeneratedID() async throws {
        let user = User.makeTest()
        let saved = try await sut.insert(user)
        XCTAssertGreaterThan(saved.id, 0)
    }

    func test_insert_persistsAllFields() async throws {
        let user = User.makeTest(
            firstName: "Anna",
            lastName: "Schmidt",
            street: "Hauptstraße",
            houseNumber: "7",
            postalCode: "10115",
            city: "Berlin",
            country: "Deutschland",
            email: "anna@test.de"
        )
        let saved = try await sut.insert(user)

        let fetched = try await sut.fetch(id: saved.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.firstName, "Anna")
        XCTAssertEqual(fetched?.lastName, "Schmidt")
        XCTAssertEqual(fetched?.street, "Hauptstraße")
        XCTAssertEqual(fetched?.houseNumber, "7")
        XCTAssertEqual(fetched?.postalCode, "10115")
        XCTAssertEqual(fetched?.city, "Berlin")
        XCTAssertEqual(fetched?.country, "Deutschland")
        XCTAssertEqual(fetched?.email, "anna@test.de")
    }

    func test_insert_emptyEmail_persistsEmpty() async throws {
        let user = User.makeTest(email: "")
        let saved = try await sut.insert(user)
        let fetched = try await sut.fetch(id: saved.id)
        XCTAssertEqual(fetched?.email, "")
    }

    // MARK: - FetchAll

    func test_fetchAll_emptyDB_returnsEmptyArray() async throws {
        let users = try await sut.fetchAll()
        XCTAssertTrue(users.isEmpty)
    }

    func test_fetchAll_afterInsert_returnsAllUsers() async throws {
        _ = try await sut.insert(User.makeTest(firstName: "Max", lastName: "Mustermann"))
        _ = try await sut.insert(User.makeTest(firstName: "Anna", lastName: "Schmidt"))
        let users = try await sut.fetchAll()
        XCTAssertEqual(users.count, 2)
    }

    func test_fetchAll_sortedByLastName() async throws {
        _ = try await sut.insert(User.makeTest(firstName: "Z", lastName: "Ziegler"))
        _ = try await sut.insert(User.makeTest(firstName: "A", lastName: "Amann"))
        _ = try await sut.insert(User.makeTest(firstName: "M", lastName: "Müller"))
        let users = try await sut.fetchAll()
        XCTAssertEqual(users[0].lastName, "Amann")
        XCTAssertEqual(users[1].lastName, "Müller")
        XCTAssertEqual(users[2].lastName, "Ziegler")
    }

    // MARK: - Update

    func test_update_changesFields() async throws {
        var user = try await sut.insert(User.makeTest(firstName: "Old", lastName: "Name"))
        user.firstName = "New"
        user.email = "new@email.com"
        try await sut.update(user)

        let fetched = try await sut.fetch(id: user.id)
        XCTAssertEqual(fetched?.firstName, "New")
        XCTAssertEqual(fetched?.email, "new@email.com")
    }

    // MARK: - Delete

    func test_delete_removesUser() async throws {
        let saved = try await sut.insert(User.makeTest())
        try await sut.delete(id: saved.id)
        let fetched = try await sut.fetch(id: saved.id)
        XCTAssertNil(fetched)
    }

    func test_delete_onlyRemovesTargetUser() async throws {
        let user1 = try await sut.insert(User.makeTest(firstName: "A"))
        let user2 = try await sut.insert(User.makeTest(firstName: "B"))
        try await sut.delete(id: user1.id)
        let remaining = try await sut.fetchAll()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.id, user2.id)
    }

    // MARK: - Suche

    func test_search_byFirstName_findsMatch() async throws {
        _ = try await sut.insert(User.makeTest(firstName: "Heinrich", lastName: "Müller"))
        _ = try await sut.insert(User.makeTest(firstName: "Max", lastName: "Mustermann"))
        let results = try await sut.search(query: "Heinrich")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.firstName, "Heinrich")
    }

    func test_search_emptyQuery_returnsAll() async throws {
        _ = try await sut.insert(User.makeTest(firstName: "A"))
        _ = try await sut.insert(User.makeTest(firstName: "B"))
        let results = try await sut.search(query: "")
        XCTAssertEqual(results.count, 2)
    }

    func test_search_noMatch_returnsEmpty() async throws {
        _ = try await sut.insert(User.makeTest(firstName: "Max"))
        let results = try await sut.search(query: "XYZNotExisting")
        XCTAssertTrue(results.isEmpty)
    }
}

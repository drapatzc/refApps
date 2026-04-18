import Foundation
@testable import App4_iOS_UserManagement

/// Mock implementation of UserRepository for tests
final class MockUserRepository: UserRepositoryProtocol {

    // MARK: - Stored Data
    private var storage: [Int64: User] = [:]
    private var nextID: Int64 = 1

    // MARK: - Error Simulation
    var shouldThrowOnFetch: Bool = false
    var shouldThrowOnInsert: Bool = false
    var shouldThrowOnUpdate: Bool = false
    var shouldThrowOnDelete: Bool = false
    var simulatedError: AppError = .databaseQueryFailed("Mock error")

    // MARK: - Call Tracking
    private(set) var fetchAllCallCount: Int = 0
    private(set) var insertCallCount: Int = 0
    private(set) var updateCallCount: Int = 0
    private(set) var deleteCallCount: Int = 0
    private(set) var lastDeletedID: Int64? = nil
    private(set) var lastInsertedUser: User? = nil
    private(set) var lastUpdatedUser: User? = nil

    // MARK: - Pre-population
    func addUser(_ user: User) {
        var u = user
        if u.id == 0 {
            u.id = nextID
            nextID += 1
        }
        storage[u.id] = u
    }

    func reset() {
        storage = [:]
        nextID = 1
        fetchAllCallCount = 0
        insertCallCount = 0
        updateCallCount = 0
        deleteCallCount = 0
        lastDeletedID = nil
        lastInsertedUser = nil
        lastUpdatedUser = nil
        shouldThrowOnFetch = false
        shouldThrowOnInsert = false
        shouldThrowOnUpdate = false
        shouldThrowOnDelete = false
    }

    // MARK: - Protocol Implementation

    func fetchAll() async throws -> [User] {
        fetchAllCallCount += 1
        if shouldThrowOnFetch { throw simulatedError }
        return storage.values.sorted { $0.lastName < $1.lastName }
    }

    func fetch(id: Int64) async throws -> User? {
        if shouldThrowOnFetch { throw simulatedError }
        return storage[id]
    }

    func search(query: String) async throws -> [User] {
        if shouldThrowOnFetch { throw simulatedError }
        let q = query.lowercased()
        return storage.values.filter {
            $0.firstName.lowercased().contains(q) ||
            $0.lastName.lowercased().contains(q) ||
            $0.email.lowercased().contains(q) ||
            $0.city.lowercased().contains(q)
        }.sorted { $0.lastName < $1.lastName }
    }

    func insert(_ user: User) async throws -> User {
        insertCallCount += 1
        if shouldThrowOnInsert { throw simulatedError }
        var saved = user
        saved.id = nextID
        nextID += 1
        storage[saved.id] = saved
        lastInsertedUser = saved
        return saved
    }

    func update(_ user: User) async throws {
        updateCallCount += 1
        if shouldThrowOnUpdate { throw simulatedError }
        guard storage[user.id] != nil else { throw AppError.recordNotFound }
        storage[user.id] = user
        lastUpdatedUser = user
    }

    func delete(id: Int64) async throws {
        deleteCallCount += 1
        if shouldThrowOnDelete { throw simulatedError }
        guard storage[id] != nil else { throw AppError.recordNotFound }
        storage.removeValue(forKey: id)
        lastDeletedID = id
    }

#if DEBUG
    func deleteAll() async throws {
        if shouldThrowOnDelete { throw simulatedError }
        storage.removeAll()
    }
#endif
}

// MARK: - Test Helper

extension User {
    static func makeTest(
        id: Int64 = 0,
        salutation: Salutation = .mr,
        firstName: String = "Max",
        lastName: String = "Mustermann",
        street: String = "Musterstraße",
        houseNumber: String = "42",
        postalCode: String = "12345",
        city: String = "Berlin",
        country: String = "Germany",
        email: String = "max@example.com"
    ) -> User {
        User(
            id: id,
            salutation: salutation,
            firstName: firstName,
            lastName: lastName,
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country,
            email: email
        )
    }
}

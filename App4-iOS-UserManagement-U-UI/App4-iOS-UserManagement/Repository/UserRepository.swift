import Foundation

/// SQLite-Implementierung des UserRepository
final class UserRepository: UserRepositoryProtocol {

    private let db: DatabaseManager

    init(db: DatabaseManager) {
        self.db = db
    }

    func fetchAll() async throws -> [User] {
        try await Task.detached(priority: .userInitiated) { [db] in
            try db.fetchAllUsers()
        }.value
    }

    func fetch(id: Int64) async throws -> User? {
        try await Task.detached(priority: .userInitiated) { [db] in
            try db.fetchUser(id: id)
        }.value
    }

    func search(query: String) async throws -> [User] {
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return try await fetchAll()
        }
        return try await Task.detached(priority: .userInitiated) { [db] in
            try db.searchUsers(query: query)
        }.value
    }

    func insert(_ user: User) async throws -> User {
        let newID = try await Task.detached(priority: .userInitiated) { [db] in
            try db.insertUser(user)
        }.value
        var saved = user
        saved.id = newID
        return saved
    }

    func update(_ user: User) async throws {
        try await Task.detached(priority: .userInitiated) { [db] in
            try db.updateUser(user)
        }.value
    }

    func delete(id: Int64) async throws {
        try await Task.detached(priority: .userInitiated) { [db] in
            try db.deleteUser(id: id)
        }.value
    }

#if DEBUG
    func deleteAll() async throws {
        try await Task.detached(priority: .userInitiated) { [db] in
            try db.deleteAllUsers()
        }.value
    }
#endif
}

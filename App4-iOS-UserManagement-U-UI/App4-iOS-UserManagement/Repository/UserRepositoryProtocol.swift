import Foundation

/// Abstracts user data access — enables testability via mock
protocol UserRepositoryProtocol {
    func fetchAll() async throws -> [User]
    func fetch(id: Int64) async throws -> User?
    func search(query: String) async throws -> [User]
    func insert(_ user: User) async throws -> User
    func update(_ user: User) async throws
    func delete(id: Int64) async throws

#if DEBUG
    func deleteAll() async throws
#endif
}

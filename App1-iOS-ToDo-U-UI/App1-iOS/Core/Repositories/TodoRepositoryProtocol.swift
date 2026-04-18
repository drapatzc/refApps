import Foundation

/// Abstracts data access for todo items.
/// Allows easy swapping of the persistence layer (e.g. InMemory ↔ CoreData).
protocol TodoRepositoryProtocol: AnyObject {
    /// Returns all stored todos sorted chronologically.
    func fetchAll() -> [Todo]

    /// Saves a new todo.
    func save(_ todo: Todo)

    /// Updates an existing todo.
    func update(_ todo: Todo)

    /// Deletes the todo with the given ID.
    func delete(id: UUID)
}

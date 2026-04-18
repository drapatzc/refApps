import Foundation
@testable import App1_iOS

/// Test double for the TodoRepository.
/// Provides controlled data access without real persistence.
final class MockTodoRepository: TodoRepositoryProtocol {

    // MARK: - Recorded Calls (for verification)

    private(set) var savedTodos: [Todo] = []
    private(set) var updatedTodos: [Todo] = []
    private(set) var deletedIDs: [UUID] = []

    // MARK: - Configurable State

    var storedTodos: [Todo] = []

    // MARK: - TodoRepositoryProtocol

    func fetchAll() -> [Todo] {
        storedTodos
    }

    func save(_ todo: Todo) {
        storedTodos.append(todo)
        savedTodos.append(todo)
    }

    func update(_ todo: Todo) {
        if let index = storedTodos.firstIndex(where: { $0.id == todo.id }) {
            storedTodos[index] = todo
        }
        updatedTodos.append(todo)
    }

    func delete(id: UUID) {
        storedTodos.removeAll { $0.id == id }
        deletedIDs.append(id)
    }
}

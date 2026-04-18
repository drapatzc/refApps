import Foundation

/// In-memory implementation of the todo repository.
/// Serves as a simple, testable data store without external dependencies.
final class InMemoryTodoRepository: TodoRepositoryProtocol {

    private var todos: [Todo] = []

    func fetchAll() -> [Todo] {
        todos.sorted { $0.createdAt < $1.createdAt }
    }

    func save(_ todo: Todo) {
        todos.append(todo)
    }

    func update(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index] = todo
    }

    func delete(id: UUID) {
        todos.removeAll { $0.id == id }
    }
}

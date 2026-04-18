import Foundation

/// Concrete implementation of todo business logic.
/// Delegates data persistence to the repository and adds validation rules.
final class TodoService: TodoServiceProtocol {

    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - TodoServiceProtocol

    func loadTodos() -> [Todo] {
        repository.fetchAll()
    }

    func createTodo(title: String) throws -> Todo {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TodoError.emptyTitle
        }
        let newTodo = Todo(title: trimmedTitle)
        repository.save(newTodo)
        return newTodo
    }

    func toggleCompletion(of todo: Todo) {
        var updated = todo
        updated.isCompleted.toggle()
        repository.update(updated)
    }

    func deleteTodo(id: UUID) {
        repository.delete(id: id)
    }
}

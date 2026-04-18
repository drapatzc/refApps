import Foundation
@testable import App1_iOS

/// Test double for the TodoService.
/// Allows testing ViewModels without real business logic.
final class MockTodoService: TodoServiceProtocol {

    // MARK: - Recorded Calls

    private(set) var toggledTodoIDs: [UUID] = []
    private(set) var deletedIDs: [UUID] = []
    private(set) var createCallCount: Int = 0

    // MARK: - Configurable State

    var storedTodos: [Todo] = []
    var createShouldThrow: Bool = false

    // MARK: - TodoServiceProtocol

    func loadTodos() -> [Todo] {
        storedTodos
    }

    func createTodo(title: String) throws -> Todo {
        createCallCount += 1
        if createShouldThrow {
            throw TodoError.emptyTitle
        }
        let todo = Todo(title: title)
        storedTodos.append(todo)
        return todo
    }

    func toggleCompletion(of todo: Todo) {
        toggledTodoIDs.append(todo.id)
    }

    func deleteTodo(id: UUID) {
        storedTodos.removeAll { $0.id == id }
        deletedIDs.append(id)
    }
}

import Foundation
import Observation

/// ViewModel for the todo list view.
/// Coordinates data loading and user actions via the service.
@Observable
final class TodoListViewModel {

    // MARK: - State

    private(set) var todos: [Todo] = []
    var isAddTodoPresented: Bool = false

    // MARK: - Dependencies

    private let service: TodoServiceProtocol

    init(service: TodoServiceProtocol) {
        self.service = service
    }

    // MARK: - Public Actions

    func loadTodos() {
        todos = service.loadTodos()
    }

    func toggleCompletion(of todo: Todo) {
        service.toggleCompletion(of: todo)
        loadTodos()
    }

    func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            service.deleteTodo(id: todos[index].id)
        }
        loadTodos()
    }

    func showAddTodo() {
        isAddTodoPresented = true
    }
}

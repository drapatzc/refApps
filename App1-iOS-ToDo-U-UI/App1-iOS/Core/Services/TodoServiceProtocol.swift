import Foundation

/// Defines the business logic for managing todos.
/// Sits between the ViewModel and Repository, encapsulating validation rules.
protocol TodoServiceProtocol: AnyObject {
    /// Loads all todos from the repository.
    func loadTodos() -> [Todo]

    /// Creates a new todo after validating the title.
    /// - Parameter title: The title of the new todo (must not be empty).
    /// - Throws: `TodoError.emptyTitle` if the title is empty.
    func createTodo(title: String) throws -> Todo

    /// Toggles the completion status of a todo.
    func toggleCompletion(of todo: Todo)

    /// Deletes the todo with the given ID.
    func deleteTodo(id: UUID)
}

// MARK: - Error Types

/// Error types for todo business logic.
enum TodoError: LocalizedError, Equatable {
    case emptyTitle

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return String(localized: "error_empty_title")
        }
    }
}

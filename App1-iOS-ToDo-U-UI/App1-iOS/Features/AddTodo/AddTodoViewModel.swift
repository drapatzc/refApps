import Foundation
import Observation

/// ViewModel for creating a new todo.
/// Encapsulates validation and delegation to the service.
@Observable
final class AddTodoViewModel {

    // MARK: - State

    var title: String = ""
    private(set) var errorMessage: String?
    private(set) var isSaved: Bool = false

    // MARK: - Dependencies

    private let service: TodoServiceProtocol

    init(service: TodoServiceProtocol) {
        self.service = service
    }

    // MARK: - Validation

    var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    func saveTodo() {
        do {
            _ = try service.createTodo(title: title)
            isSaved = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

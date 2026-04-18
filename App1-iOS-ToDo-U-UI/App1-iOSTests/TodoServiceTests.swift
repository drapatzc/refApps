import Testing
import Foundation
@testable import App1_iOS

/// Tests for the TodoService business logic.
struct TodoServiceTests {

    private func makeSUT() -> (service: TodoService, repository: MockTodoRepository) {
        let repository = MockTodoRepository()
        let service = TodoService(repository: repository)
        return (service, repository)
    }

    // MARK: - Loading

    @Test("Todos are loaded correctly from the repository")
    func todosAreLoadedFromRepository() {
        let (service, repository) = makeSUT()
        repository.storedTodos = [Todo(title: "Vorhanden")]
        let todos = service.loadTodos()
        #expect(todos.count == 1)
        #expect(todos.first?.title == "Vorhanden")
    }

    // MARK: - Creating

    @Test("New todo is saved with trimmed title")
    func newTodoIsSavedWithTrimmedTitle() throws {
        let (service, repository) = makeSUT()
        let todo = try service.createTodo(title: "  Mein Todo  ")
        #expect(todo.title == "Mein Todo")
        #expect(repository.savedTodos.count == 1)
        #expect(repository.savedTodos.first?.title == "Mein Todo")
    }

    @Test("Empty title throws TodoError.emptyTitle")
    func emptyTitleThrowsTodoError() {
        let (service, _) = makeSUT()
        #expect(throws: TodoError.emptyTitle) {
            try service.createTodo(title: "   ")
        }
    }

    @Test("Whitespace-only title throws error")
    func whitespaceOnlyTitleThrowsError() {
        let (service, _) = makeSUT()
        #expect(throws: TodoError.emptyTitle) {
            try service.createTodo(title: "\n\t ")
        }
    }

    @Test("Valid title creates todo without error")
    func validTitleCreatesTodoWithoutError() throws {
        let (service, _) = makeSUT()
        let todo = try service.createTodo(title: "Valider Titel")
        #expect(todo.title == "Valider Titel")
        #expect(todo.isCompleted == false)
    }

    // MARK: - Toggling Status

    @Test("Completion status is toggled via repository")
    func completionStatusIsToggledViaRepository() {
        let (service, repository) = makeSUT()
        let todo = Todo(title: "Toggle Test", isCompleted: false)
        repository.storedTodos = [todo]
        service.toggleCompletion(of: todo)
        #expect(repository.updatedTodos.count == 1)
        #expect(repository.updatedTodos.first?.isCompleted == true)
    }

    // MARK: - Deleting

    @Test("Todo is correctly deleted via repository")
    func todoIsDeletedViaRepository() {
        let (service, repository) = makeSUT()
        let todoID = UUID()
        service.deleteTodo(id: todoID)
        #expect(repository.deletedIDs.contains(todoID))
    }
}

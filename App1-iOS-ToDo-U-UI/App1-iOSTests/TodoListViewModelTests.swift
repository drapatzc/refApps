import Testing
import Foundation
@testable import App1_iOS

/// Tests for TodoListViewModel.
struct TodoListViewModelTests {

    private func makeSUT(initialTodos: [Todo] = []) -> (viewModel: TodoListViewModel, service: MockTodoService) {
        let service = MockTodoService()
        service.storedTodos = initialTodos
        let viewModel = TodoListViewModel(service: service)
        return (viewModel, service)
    }

    // MARK: - Loading

    @Test("Todos are correctly set on load")
    func todosAreSetOnLoad() {
        let testTodos = [Todo(title: "Erster"), Todo(title: "Zweiter")]
        let (viewModel, _) = makeSUT(initialTodos: testTodos)
        viewModel.loadTodos()
        #expect(viewModel.todos.count == 2)
    }

    @Test("Empty list is displayed correctly with empty service")
    func emptyListIsDisplayedWithEmptyService() {
        let (viewModel, _) = makeSUT()
        viewModel.loadTodos()
        #expect(viewModel.todos.isEmpty)
    }

    // MARK: - Adding

    @Test("isAddTodoPresented becomes true when tapping add")
    func isAddTodoPresentedBecomesTrue() {
        let (viewModel, _) = makeSUT()
        viewModel.showAddTodo()
        #expect(viewModel.isAddTodoPresented == true)
    }

    // MARK: - Toggling Status

    @Test("Toggle calls service and reloads todos")
    func toggleCallsServiceAndReloadsTodos() {
        let todo = Todo(title: "Zu toggeln")
        let (viewModel, service) = makeSUT(initialTodos: [todo])
        viewModel.loadTodos()
        viewModel.toggleCompletion(of: todo)
        #expect(service.toggledTodoIDs.contains(todo.id))
    }

    // MARK: - Deleting

    @Test("Deleting todos calls service correctly")
    func deletingTodosCallsService() {
        let testTodos = [Todo(title: "Zu löschen")]
        let (viewModel, service) = makeSUT(initialTodos: testTodos)
        viewModel.loadTodos()
        viewModel.deleteTodos(at: IndexSet([0]))
        #expect(service.deletedIDs.count == 1)
    }

    @Test("Todos are reloaded after deletion")
    func todosAreReloadedAfterDeletion() {
        let (viewModel, service) = makeSUT(initialTodos: [Todo(title: "Test")])
        viewModel.loadTodos()
        service.storedTodos = [] // service deletes internally
        viewModel.deleteTodos(at: IndexSet([0]))
        #expect(viewModel.todos.isEmpty)
    }
}

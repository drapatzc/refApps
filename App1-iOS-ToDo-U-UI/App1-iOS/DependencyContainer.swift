import Foundation

/// Manages all app dependencies (Dependency Injection Container).
/// Provides pre-configured instances of services and repositories.
final class DependencyContainer {

    static let shared = DependencyContainer()

    private init() {}

    // MARK: - Repositories

    private(set) lazy var todoRepository: TodoRepositoryProtocol = {
        InMemoryTodoRepository()
    }()

    // MARK: - Services

    private(set) lazy var todoService: TodoServiceProtocol = {
        TodoService(repository: todoRepository)
    }()

    // MARK: - ViewModels

    func makeTodoListViewModel() -> TodoListViewModel {
        TodoListViewModel(service: todoService)
    }

    func makeAddTodoViewModel() -> AddTodoViewModel {
        AddTodoViewModel(service: todoService)
    }
}

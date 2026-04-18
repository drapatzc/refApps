import Foundation

/// All possible actions that can change the application state.
/// In the Redux pattern, actions are dispatched to the store, which calls the reducer.
enum AppAction: Equatable {
    case addTask(title: String, description: String, priority: TaskPriority)
    case updateTaskStatus(id: UUID, newStatus: TaskStatus)
    case deleteTask(id: UUID)
    case selectTask(id: UUID?)
    case setFilter(status: TaskStatus?)
    case showAddTask
    case hideAddTask
    case clearError
}

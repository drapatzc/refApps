import Foundation

/// All possible actions that can change the application state.
/// In the Redux pattern, actions are dispatched to the store, which calls the reducer.
enum AppAction: Equatable {
    case addTask(title: String, description: String, priority: TaskPriority, dueDate: Date?, category: TaskCategory, tags: [String])
    case updateTask(id: UUID, title: String, description: String, priority: TaskPriority, status: TaskStatus, dueDate: Date?, category: TaskCategory, tags: [String])
    case updateTaskStatus(id: UUID, newStatus: TaskStatus)
    case deleteTask(id: UUID)
    case selectTask(id: UUID?)
    case setFilter(status: TaskStatus?)
    case setCategoryFilter(category: TaskCategory?)
    case setSearchQuery(String)
    case setSortOrder(TaskSortOrder)
    case showAddTask
    case hideAddTask
    case showEditTask(id: UUID)
    case hideEditTask
    case clearError
    case loadSampleData
}

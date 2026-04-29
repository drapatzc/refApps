import Foundation

/// Complete, immutable application state (Single Source of Truth).
/// In the Redux pattern, AppState is the app's only data source.
struct AppState: Equatable {

    // MARK: - Data

    var tasks: [WorkTask] = []

    // MARK: - Filters and Sort

    var filterStatus: TaskStatus?
    var filterCategory: TaskCategory?
    var searchQuery: String = ""
    var sortOrder: TaskSortOrder = .priority

    // MARK: - Navigation and UI State

    var selectedTaskID: UUID?
    var isAddTaskPresented: Bool = false
    var isEditTaskPresented: Bool = false
    var editingTaskID: UUID?
    var errorMessage: String?

    // MARK: - Computed Properties

    /// Returns tasks filtered by status, category, search query, and sorted by the active sort order.
    var filteredTasks: [WorkTask] {
        var result = tasks

        if let filterStatus {
            result = result.filter { $0.status == filterStatus }
        }
        if let filterCategory {
            result = result.filter { $0.category == filterCategory }
        }
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.taskDescription.lowercased().contains(query) ||
                $0.tags.contains { $0.lowercased().contains(query) }
            }
        }

        return result.sorted(by: sortOrder)
    }

    /// Returns the currently selected task.
    var selectedTask: WorkTask? {
        guard let selectedTaskID else { return nil }
        return tasks.first { $0.id == selectedTaskID }
    }

    /// Returns the task currently being edited.
    var editingTask: WorkTask? {
        guard let editingTaskID else { return nil }
        return tasks.first { $0.id == editingTaskID }
    }
}

// MARK: - Sort Helper

private extension Array where Element == WorkTask {
    func sorted(by order: TaskSortOrder) -> [WorkTask] {
        switch order {
        case .priority:
            return sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .dueDate:
            return sorted {
                switch ($0.dueDate, $1.dueDate) {
                case (nil, nil): return false
                case (nil, _): return false
                case (_, nil): return true
                case (let lhs?, let rhs?): return lhs < rhs
                }
            }
        case .title:
            return sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .createdAt:
            return sorted { $0.createdAt > $1.createdAt }
        }
    }
}

import Foundation

/// Complete, immutable application state (Single Source of Truth).
/// In the Redux pattern, AppState is the app's only data source.
struct AppState: Equatable {

    // MARK: - Data

    var tasks: [WorkTask] = []

    // MARK: - Navigation and UI State

    var selectedTaskID: UUID?
    var filterStatus: TaskStatus?
    var isAddTaskPresented: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

    /// Returns filtered tasks sorted by priority.
    var filteredTasks: [WorkTask] {
        let filtered: [WorkTask]
        if let filterStatus {
            filtered = tasks.filter { $0.status == filterStatus }
        } else {
            filtered = tasks
        }
        return filtered.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }

    /// Returns the currently selected task.
    var selectedTask: WorkTask? {
        guard let selectedTaskID else { return nil }
        return tasks.first { $0.id == selectedTaskID }
    }
}

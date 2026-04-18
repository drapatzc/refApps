import Foundation

/// Pure function that computes a new state from the current state and an action.
/// The reducer is the core of the Redux pattern:
/// - No side effects
/// - No external dependencies
/// - Same input → same output (deterministic)
func appReducer(state: AppState, action: AppAction) -> AppState {
    var newState = state

    switch action {

    case let .addTask(title, description, priority):
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            newState.errorMessage = String(localized: "error_empty_title")
            return newState
        }
        let newTask = WorkTask(title: trimmedTitle, taskDescription: description, priority: priority)
        newState.tasks.append(newTask)
        newState.isAddTaskPresented = false
        newState.errorMessage = nil

    case let .updateTaskStatus(id, newStatus):
        if let index = newState.tasks.firstIndex(where: { $0.id == id }) {
            newState.tasks[index].status = newStatus
        }

    case let .deleteTask(id):
        newState.tasks.removeAll { $0.id == id }
        if newState.selectedTaskID == id {
            newState.selectedTaskID = nil
        }

    case let .selectTask(id):
        newState.selectedTaskID = id

    case let .setFilter(status):
        newState.filterStatus = status

    case .showAddTask:
        newState.isAddTaskPresented = true
        newState.errorMessage = nil

    case .hideAddTask:
        newState.isAddTaskPresented = false

    case .clearError:
        newState.errorMessage = nil
    }

    return newState
}

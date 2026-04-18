import Foundation

/// A single work task with title, description, priority, and status.
struct WorkTask: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var taskDescription: String
    var priority: TaskPriority
    var status: TaskStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .todo,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.priority = priority
        self.status = status
        self.createdAt = createdAt
    }
}

// MARK: - Priority

/// Priority levels for work tasks.
enum TaskPriority: String, CaseIterable, Codable {
    case low
    case medium
    case high

    /// Sort order: lower value = higher priority in display.
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }

    /// Localized display name for the priority.
    var localizedName: String {
        switch self {
        case .low: return String(localized: "priority_low")
        case .medium: return String(localized: "priority_medium")
        case .high: return String(localized: "priority_high")
        }
    }
}

// MARK: - Status

/// Processing status for work tasks.
enum TaskStatus: String, CaseIterable, Codable {
    case todo
    case inProgress
    case done

    /// Localized display name for the status.
    var localizedName: String {
        switch self {
        case .todo: return String(localized: "status_open")
        case .inProgress: return String(localized: "status_in_progress")
        case .done: return String(localized: "status_done")
        }
    }
}

import Foundation

/// A single work task with title, description, priority, status, due date, tags, and category.
struct WorkTask: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var taskDescription: String
    var priority: TaskPriority
    var status: TaskStatus
    var dueDate: Date?
    var tags: [String]
    var category: TaskCategory
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .todo,
        dueDate: Date? = nil,
        tags: [String] = [],
        category: TaskCategory = .general,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.tags = tags
        self.category = category
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

// MARK: - Category

/// Category for grouping work tasks.
enum TaskCategory: String, CaseIterable, Codable {
    case general
    case work
    case personal
    case shopping
    case health

    /// Localized display name for the category.
    var localizedName: String {
        switch self {
        case .general: return String(localized: "category_general")
        case .work: return String(localized: "category_work")
        case .personal: return String(localized: "category_personal")
        case .shopping: return String(localized: "category_shopping")
        case .health: return String(localized: "category_health")
        }
    }

    /// SF Symbol name for the category.
    var systemImage: String {
        switch self {
        case .general: return "tray"
        case .work: return "briefcase"
        case .personal: return "person"
        case .shopping: return "cart"
        case .health: return "heart"
        }
    }
}

// MARK: - Sort Order

/// Sort order for the task list.
enum TaskSortOrder: String, CaseIterable, Equatable {
    case priority
    case dueDate
    case title
    case createdAt

    /// Localized display name for the sort order.
    var localizedName: String {
        switch self {
        case .priority: return String(localized: "sort_priority")
        case .dueDate: return String(localized: "sort_due_date")
        case .title: return String(localized: "sort_title")
        case .createdAt: return String(localized: "sort_created_at")
        }
    }
}

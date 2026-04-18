import SwiftUI

/// Sidebar of the macOS app: displays all tasks with filter and sort functionality.
struct TaskListView: View {

    let store: AppStore

    var body: some View {
        List(store.state.filteredTasks, selection: Binding(
            get: { store.state.selectedTaskID },
            set: { store.dispatch(.selectTask(id: $0)) }
        )) { task in
            TaskRowView(task: task)
                .tag(task.id)
        }
        .listStyle(.sidebar)
        .navigationTitle(String(localized: "tasks_nav_title"))
        .toolbar {
            ToolbarItemGroup {
                filterMenuButton
                addTaskButton
            }
        }
        .accessibilityIdentifier("taskList")
        .overlay {
            if store.state.filteredTasks.isEmpty {
                emptyStateView
            }
        }
    }

    // MARK: - Toolbar Items

    private var addTaskButton: some View {
        Button(action: { store.dispatch(.showAddTask) }) {
            Label(String(localized: "new_task"), systemImage: "plus")
        }
        .accessibilityIdentifier("addTaskButton")
        .help(String(localized: "new_task_tooltip"))
    }

    private var filterMenuButton: some View {
        Menu {
            Button(String(localized: "show_all")) {
                store.dispatch(.setFilter(status: nil))
            }
            Divider()
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button(status.localizedName) {
                    store.dispatch(.setFilter(status: status))
                }
            }
        } label: {
            Label(String(localized: "filter"), systemImage: "line.3.horizontal.decrease.circle")
        }
        .help(String(localized: "filter_tasks_tooltip"))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView(
            String(localized: "no_tasks"),
            systemImage: "tray",
            description: Text(String(localized: "no_tasks_hint"))
        )
    }
}

// MARK: - Task Row

/// A single row in the task sidebar.
private struct TaskRowView: View {

    let task: WorkTask

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                priorityDot
                Text(task.title)
                    .font(.headline)
                    .lineLimit(1)
            }
            Text(task.status.localizedName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(format: String(localized: "accessibility_task_label"),
                   task.title,
                   task.priority.localizedName,
                   task.status.localizedName)
        )
    }

    private var priorityDot: some View {
        Circle()
            .fill(task.priority.color)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Display Extensions

private extension TaskPriority {
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

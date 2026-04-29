import SwiftUI

/// Sidebar of the macOS app: displays all tasks with search, filter, and sort functionality.
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
        .searchable(
            text: Binding(
                get: { store.state.searchQuery },
                set: { store.dispatch(.setSearchQuery($0)) }
            ),
            prompt: String(localized: "search_placeholder")
        )
        .toolbar {
            ToolbarItem(placement: .automatic) {
                sortMenuButton
            }
            ToolbarItem(placement: .automatic) {
                filterMenuButton
            }
            ToolbarItem(placement: .automatic) {
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
            Section(String(localized: "filter_by_status")) {
                Button(String(localized: "show_all")) {
                    store.dispatch(.setFilter(status: nil))
                }
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Button {
                        store.dispatch(.setFilter(status: status))
                    } label: {
                        if store.state.filterStatus == status {
                            Label(status.localizedName, systemImage: "checkmark")
                        } else {
                            Text(status.localizedName)
                        }
                    }
                }
            }
            Section(String(localized: "filter_by_category")) {
                Button(String(localized: "filter_all_categories")) {
                    store.dispatch(.setCategoryFilter(category: nil))
                }
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    Button {
                        store.dispatch(.setCategoryFilter(category: category))
                    } label: {
                        if store.state.filterCategory == category {
                            Label(category.localizedName, systemImage: "checkmark")
                        } else {
                            Label(category.localizedName, systemImage: category.systemImage)
                        }
                    }
                }
            }
        } label: {
            Label(String(localized: "filter"), systemImage: "line.3.horizontal.decrease.circle")
        }
        .help(String(localized: "filter_tasks_tooltip"))
    }

    private var sortMenuButton: some View {
        Menu {
            ForEach(TaskSortOrder.allCases, id: \.self) { order in
                Button {
                    store.dispatch(.setSortOrder(order))
                } label: {
                    if store.state.sortOrder == order {
                        Label(order.localizedName, systemImage: "checkmark")
                    } else {
                        Text(order.localizedName)
                    }
                }
            }
        } label: {
            Label(String(localized: "sort_by"), systemImage: "arrow.up.arrow.down")
        }
        .help(String(localized: "sort_menu_tooltip"))
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
                Spacer()
                if let dueDate = task.dueDate {
                    dueDateBadge(dueDate)
                }
            }
            HStack(spacing: 8) {
                Text(task.status.localizedName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(task.category.localizedName, systemImage: task.category.systemImage)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .labelStyle(.titleAndIcon)
            }
        }
        .padding(.vertical, 2)
    }

    private var priorityDot: some View {
        Circle()
            .fill(task.priority.color)
            .frame(width: 8, height: 8)
    }

    private func dueDateBadge(_ date: Date) -> some View {
        let isOverdue = date < Date() && task.status != .done
        return Text(date.formatted(date: .abbreviated, time: .omitted))
            .font(.caption2)
            .foregroundStyle(isOverdue ? .red : .secondary)
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

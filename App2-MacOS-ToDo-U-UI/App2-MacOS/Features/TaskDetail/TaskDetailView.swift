import SwiftUI

/// Detail view for the currently selected task.
struct TaskDetailView: View {

    let store: AppStore

    var body: some View {
        if let task = store.state.selectedTask {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    metadataSection(for: task)
                    if !task.taskDescription.isEmpty {
                        descriptionSection(for: task)
                    }
                    if !task.tags.isEmpty {
                        tagsSection(for: task)
                    }
                    statusSection(for: task)
                    Spacer()
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .navigationTitle(task.title)
            .navigationSubtitle(task.status.localizedName)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.dispatch(.showEditTask(id: task.id))
                    } label: {
                        Label(String(localized: "edit_task"), systemImage: "pencil")
                    }
                    .help(String(localized: "edit_task_tooltip"))
                    .accessibilityIdentifier("editTaskButton")
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        store.dispatch(.deleteTask(id: task.id))
                    } label: {
                        Label(String(localized: "delete"), systemImage: "trash")
                    }
                    .help(String(localized: "delete_task_tooltip"))
                    .accessibilityIdentifier("deleteTaskButton")
                }
            }
        }
    }

    // MARK: - Sections

    private func metadataSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                String(format: String(localized: "priority_label"), task.priority.localizedName),
                systemImage: "flag.fill"
            )
            .foregroundStyle(task.priority.displayColor)
            .font(.subheadline)

            Label(
                String(format: String(localized: "category_label"), task.category.localizedName),
                systemImage: task.category.systemImage
            )
            .foregroundStyle(.secondary)
            .font(.subheadline)

            if let dueDate = task.dueDate {
                let isOverdue = dueDate < Date() && task.status != .done
                Label(
                    String(format: String(localized: "due_date_label"), dueDate.formatted(date: .long, time: .omitted)),
                    systemImage: "clock"
                )
                .foregroundStyle(isOverdue ? .red : .secondary)
                .font(.subheadline)
            }

            Label(
                String(format: String(localized: "created_label"), task.createdAt.formatted(date: .long, time: .omitted)),
                systemImage: "calendar"
            )
            .foregroundStyle(.secondary)
            .font(.subheadline)
        }
    }

    private func descriptionSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "section_description"))
                .font(.headline)
            Text(task.taskDescription)
                .foregroundStyle(.secondary)
        }
    }

    private func tagsSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "section_tags"))
                .font(.headline)
            TagsFlowView(tags: task.tags)
        }
    }

    private func statusSection(for task: WorkTask) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "change_status"))
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Button(status.localizedName) {
                        store.dispatch(.updateTaskStatus(id: task.id, newStatus: status))
                    }
                    .buttonStyle(.bordered)
                    .tint(task.status == status ? Color.accentColor : nil)
                    .accessibilityIdentifier("statusButton_\(status.rawValue)")
                }
            }
        }
    }
}

// MARK: - Tags Flow View

/// Displays tags as rounded capsule badges.
private struct TagsFlowView: View {

    let tags: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Extensions

private extension TaskPriority {
    var displayColor: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

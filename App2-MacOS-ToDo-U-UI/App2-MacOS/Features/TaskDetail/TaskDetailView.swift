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
                    statusSection(for: task)
                }
                .padding(24)
            }
            .navigationTitle(task.title)
            .navigationSubtitle(task.status.localizedName)
            .toolbar {
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

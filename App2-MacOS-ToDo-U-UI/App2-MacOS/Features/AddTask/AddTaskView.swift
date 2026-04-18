import SwiftUI

/// Input form for new tasks.
/// Presented as a sheet and dispatches an addTask action to the store.
struct AddTaskView: View {

    let store: AppStore
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var priority: TaskPriority = .medium
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar
            Divider()
            Form {
                Section(String(localized: "section_title_required")) {
                    TextField(String(localized: "task_title_placeholder"), text: $title)
                        .accessibilityIdentifier("taskTitleField")
                }

                Section(String(localized: "section_description")) {
                    TextEditor(text: $taskDescription)
                        .frame(minHeight: 80)
                }

                Section(String(localized: "section_priority")) {
                    Picker(String(localized: "section_priority"), selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { prio in
                            Text(prio.localizedName).tag(prio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let errorMessage = store.state.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(Color.red)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 420, minHeight: 360)
        .onChange(of: store.state.isAddTaskPresented) { _, isPresented in
            if !isPresented {
                dismiss()
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button(String(localized: "cancel")) {
                store.dispatch(.hideAddTask)
            }
            .keyboardShortcut(.cancelAction)

            Spacer()

            Text(String(localized: "new_task"))
                .font(.headline)

            Spacer()

            Button(String(localized: "add")) {
                store.dispatch(.addTask(
                    title: title,
                    description: taskDescription,
                    priority: priority
                ))
            }
            .keyboardShortcut(.defaultAction)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("addTaskConfirmButton")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

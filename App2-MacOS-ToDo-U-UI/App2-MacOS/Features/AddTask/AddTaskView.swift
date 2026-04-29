import SwiftUI

// MARK: - Add Task View

/// Input form for new tasks.
/// Presented as a sheet and dispatches an addTask action to the store.
struct AddTaskView: View {

    let store: AppStore
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var category: TaskCategory = .general
    @State private var tagsText: String = ""
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
                        .frame(minHeight: 60)
                }

                Section(String(localized: "section_priority")) {
                    Picker(String(localized: "section_priority"), selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { prio in
                            Text(prio.localizedName).tag(prio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "section_category")) {
                    Picker(String(localized: "section_category"), selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Label(cat.localizedName, systemImage: cat.systemImage).tag(cat)
                        }
                    }
                }

                Section(String(localized: "section_due_date")) {
                    Toggle(String(localized: "due_date"), isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            String(localized: "due_date"),
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }

                Section(String(localized: "section_tags")) {
                    TextField(String(localized: "tags_placeholder"), text: $tagsText)
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
        .frame(minWidth: 420, minHeight: 460)
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
                    priority: priority,
                    dueDate: hasDueDate ? dueDate : nil,
                    category: category,
                    tags: parseTags(tagsText)
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

// MARK: - Edit Task View

/// Editing form for an existing task.
/// Pre-populated with all current task fields.
struct EditTaskView: View {

    let store: AppStore
    let task: WorkTask

    @State private var title: String
    @State private var taskDescription: String
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var category: TaskCategory
    @State private var tagsText: String
    @Environment(\.dismiss) private var dismiss

    init(store: AppStore, task: WorkTask) {
        self.store = store
        self.task = task
        _title = State(initialValue: task.title)
        _taskDescription = State(initialValue: task.taskDescription)
        _priority = State(initialValue: task.priority)
        _status = State(initialValue: task.status)
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _category = State(initialValue: task.category)
        _tagsText = State(initialValue: task.tags.joined(separator: ", "))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar
            Divider()
            Form {
                Section(String(localized: "section_title_required")) {
                    TextField(String(localized: "task_title_placeholder"), text: $title)
                        .accessibilityIdentifier("editTaskTitleField")
                }

                Section(String(localized: "section_description")) {
                    TextEditor(text: $taskDescription)
                        .frame(minHeight: 60)
                }

                Section(String(localized: "section_priority")) {
                    Picker(String(localized: "section_priority"), selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { prio in
                            Text(prio.localizedName).tag(prio)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "section_status")) {
                    Picker(String(localized: "section_status"), selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { stat in
                            Text(stat.localizedName).tag(stat)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "section_category")) {
                    Picker(String(localized: "section_category"), selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Label(cat.localizedName, systemImage: cat.systemImage).tag(cat)
                        }
                    }
                }

                Section(String(localized: "section_due_date")) {
                    Toggle(String(localized: "due_date"), isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            String(localized: "due_date"),
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }

                Section(String(localized: "section_tags")) {
                    TextField(String(localized: "tags_placeholder"), text: $tagsText)
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
        .frame(minWidth: 420, minHeight: 520)
        .onChange(of: store.state.isEditTaskPresented) { _, isPresented in
            if !isPresented {
                dismiss()
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Button(String(localized: "cancel")) {
                store.dispatch(.hideEditTask)
            }
            .keyboardShortcut(.cancelAction)

            Spacer()

            Text(String(localized: "edit_task"))
                .font(.headline)

            Spacer()

            Button(String(localized: "save")) {
                store.dispatch(.updateTask(
                    id: task.id,
                    title: title,
                    description: taskDescription,
                    priority: priority,
                    status: status,
                    dueDate: hasDueDate ? dueDate : nil,
                    category: category,
                    tags: parseTags(tagsText)
                ))
            }
            .keyboardShortcut(.defaultAction)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("saveTaskButton")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Helpers

/// Parses a comma-separated tag string into a trimmed, non-empty array.
private func parseTags(_ text: String) -> [String] {
    text.components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

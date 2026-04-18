import SwiftUI

/// Input form for creating a new todo.
struct AddTodoView: View {

    @State private var viewModel: AddTodoViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AddTodoViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "section_title")) {
                    TextField(String(localized: "todo_placeholder"), text: $viewModel.title)
                        .accessibilityIdentifier("todoTitleField")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(Color.red)
                    }
                }
            }
            .navigationTitle(String(localized: "new_todo_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) {
                        viewModel.saveTodo()
                    }
                    .disabled(!viewModel.isTitleValid)
                    .accessibilityIdentifier("saveTodoButton")
                }
            }
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }
}

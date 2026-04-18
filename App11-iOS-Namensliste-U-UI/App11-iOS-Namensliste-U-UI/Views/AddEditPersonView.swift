import SwiftUI
import SwiftData

enum PersonDialogMode {
    case add
    case edit
}

struct AddEditPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: PersonViewModel
    let mode: PersonDialogMode

    private var title: String {
        mode == .add ? "Neuer Name" : "Name bearbeiten"
    }

    private var confirmButtonTitle: String {
        mode == .add ? "Speichern" : "Aktualisieren"
    }

    var body: some View {
        NavigationStack {
            Form {
                vornameSection
                nachnameSection
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelButton
                confirmButton
            }
        }
        .liquidGlassPresentation()
    }

    // MARK: - Sections

    private var vornameSection: some View {
        Section {
            TextField("Vorname eingeben", text: $viewModel.vorname)
                .autocorrectionDisabled()
                .textContentType(.givenName)
            if viewModel.vornameError {
                Text("Vorname ist ein Pflichtfeld.")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        } header: {
            Text("Vorname")
        }
    }

    private var nachnameSection: some View {
        Section {
            TextField("Nachnamen eingeben", text: $viewModel.nachname)
                .autocorrectionDisabled()
                .textContentType(.familyName)
            if viewModel.nachnameError {
                Text("Nachname ist ein Pflichtfeld.")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        } header: {
            Text("Nachname")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Abbrechen") {
                dismissDialog()
            }
        }
    }

    @ToolbarContentBuilder
    private var confirmButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(confirmButtonTitle) {
                saveOrUpdate()
            }
            .fontWeight(.semibold)
        }
    }

    // MARK: - Actions

    private func dismissDialog() {
        if mode == .add {
            viewModel.showAddDialog = false
        } else {
            viewModel.showEditDialog = false
        }
    }

    private func saveOrUpdate() {
        if mode == .add {
            viewModel.addPerson(in: modelContext)
        } else {
            viewModel.updatePerson(in: modelContext)
        }
    }
}

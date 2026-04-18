import SwiftUI
import SwiftData

struct PersonListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Person.nachname), SortDescriptor(\Person.vorname)])
    private var persons: [Person]

    @State private var viewModel = PersonViewModel()
    @State private var personToDelete: Person?

    var body: some View {
        NavigationStack {
            Group {
                if persons.isEmpty {
                    EmptyStateView()
                } else {
                    personList
                }
            }
            .navigationTitle("Namensliste")
            .toolbar {
                leadingToolbarContent
                trailingToolbarContent
            }
        }
        .sheet(isPresented: $viewModel.showAddDialog) {
            AddEditPersonView(viewModel: viewModel, mode: .add)
        }
        .sheet(isPresented: $viewModel.showEditDialog) {
            AddEditPersonView(viewModel: viewModel, mode: .edit)
        }
        .confirmationDialog(
            "Person löschen?",
            isPresented: Binding(
                get: { personToDelete != nil },
                set: { if !$0 { personToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Ja", role: .destructive) {
                if let person = personToDelete {
                    viewModel.deletePerson(person, in: modelContext)
                }
                personToDelete = nil
            }
            Button("Nein", role: .cancel) {
                personToDelete = nil
            }
        } message: {
            if let person = personToDelete {
                Text("Möchten Sie \"\(person.vollerName)\" wirklich löschen?")
            }
        }
        .confirmationDialog(
            "100 Beispieldaten anlegen?",
            isPresented: $viewModel.showSampleDataConfirmation,
            titleVisibility: .visible
        ) {
            Button("Ja") {
                SampleDataService.createSampleData(in: modelContext)
            }
            Button("Nein", role: .cancel) {}
        } message: {
            Text("Es werden 100 Beispieleinträge angelegt.")
        }
        .confirmationDialog(
            "Alle Einträge löschen?",
            isPresented: $viewModel.showDeleteAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Ja", role: .destructive) {
                viewModel.deleteAll(persons, in: modelContext)
            }
            Button("Nein", role: .cancel) {}
        } message: {
            Text("Möchten Sie wirklich alle \(persons.count) Einträge löschen?")
        }
    }

    // MARK: - List

    private var personList: some View {
        List {
            ForEach(persons) { person in
                Text(person.vollerName)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            personToDelete = person
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            viewModel.prepareForEdit(person)
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .liquidGlassListBackground()
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var leadingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button {
                    viewModel.showSampleDataConfirmation = true
                } label: {
                    Label("Beispieldaten", systemImage: "person.3.fill")
                }
                Divider()
                Button(role: .destructive) {
                    viewModel.showDeleteAllConfirmation = true
                } label: {
                    Label("Alles löschen", systemImage: "trash.fill")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .accessibilityLabel("Menü")
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.prepareForAdd()
            } label: {
                Image(systemName: "plus")
                    .accessibilityLabel("Neuen Namen hinzufügen")
            }
        }
    }
}

#Preview {
    PersonListView()
        .modelContainer(for: Person.self, inMemory: true)
}

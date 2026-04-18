import Foundation
import SwiftData
import Observation

@Observable
final class PersonViewModel {

    // MARK: - Dialog States
    var showAddDialog: Bool = false
    var showEditDialog: Bool = false
    var showSampleDataConfirmation: Bool = false
    var showDeleteAllConfirmation: Bool = false

    // MARK: - Form Fields
    var vorname: String = ""
    var nachname: String = ""
    var vornameError: Bool = false
    var nachnameError: Bool = false

    // MARK: - Selection
    var selectedPerson: Person?

    // MARK: - Prepare
    func prepareForAdd() {
        vorname = ""
        nachname = ""
        vornameError = false
        nachnameError = false
        showAddDialog = true
    }

    func prepareForEdit(_ person: Person) {
        selectedPerson = person
        vorname = person.vorname
        nachname = person.nachname
        vornameError = false
        nachnameError = false
        showEditDialog = true
    }

    // MARK: - Validation
    @discardableResult
    func validateInput() -> Bool {
        vornameError = vorname.trimmingCharacters(in: .whitespaces).isEmpty
        nachnameError = nachname.trimmingCharacters(in: .whitespaces).isEmpty
        return !vornameError && !nachnameError
    }

    // MARK: - CRUD
    func addPerson(in context: ModelContext) {
        guard validateInput() else { return }
        let person = Person(
            vorname: vorname.trimmingCharacters(in: .whitespaces),
            nachname: nachname.trimmingCharacters(in: .whitespaces)
        )
        context.insert(person)
        showAddDialog = false
    }

    func updatePerson(in context: ModelContext) {
        guard validateInput(), let person = selectedPerson else { return }
        person.vorname = vorname.trimmingCharacters(in: .whitespaces)
        person.nachname = nachname.trimmingCharacters(in: .whitespaces)
        try? context.save()
        showEditDialog = false
        selectedPerson = nil
    }

    func deletePerson(_ person: Person, in context: ModelContext) {
        context.delete(person)
    }

    func deleteAll(_ persons: [Person], in context: ModelContext) {
        persons.forEach { context.delete($0) }
    }
}

import SwiftData
import Observation
import Foundation

@Observable final class DocumentViewModel {
    var documents: [InsuranceDocument] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showSuccess: Bool = false

    private var repository: DocumentRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = DocumentRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadDocuments()
    }

    func loadDocuments() {
        guard let person else { return }
        documents = repository?.fetchAll(for: person) ?? []
    }

    func add(
        title: String,
        documentType: String,
        fileData: Data,
        notes: String?
    ) throws {
        guard let person, let repository else { return }
        try repository.add(
            title: title,
            documentType: documentType,
            fileData: fileData,
            notes: notes,
            to: person
        )
        loadDocuments()
        showSuccess = true
    }

    func delete(_ document: InsuranceDocument) throws {
        try repository?.delete(document)
        loadDocuments()
    }
}

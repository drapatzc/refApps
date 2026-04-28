import SwiftData
import Foundation

final class DocumentRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(for person: InsuredPerson) -> [InsuranceDocument] {
        person.documents.sorted { $0.uploadDate > $1.uploadDate }
    }

    func add(
        title: String,
        documentType: String,
        fileData: Data,
        notes: String?,
        to person: InsuredPerson
    ) throws {
        let errors = DocumentValidator.validate(title: title, fileData: fileData)
        guard errors.isEmpty else { throw errors.first! }

        let document = InsuranceDocument(
            title: title,
            documentType: documentType,
            uploadDate: Date(),
            fileData: fileData,
            notes: notes
        )
        person.documents.append(document)
        try context.save()
    }

    func delete(_ document: InsuranceDocument) throws {
        context.delete(document)
        try context.save()
    }
}

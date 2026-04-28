import SwiftData
import Foundation

@Model final class InsuranceDocument {
    var id: UUID = UUID()
    var title: String
    var documentType: String
    var uploadDate: Date
    @Attribute(.externalStorage) var fileData: Data
    var notes: String?

    @Relationship(deleteRule: .nullify)
    var person: InsuredPerson?

    init(
        id: UUID = UUID(),
        title: String,
        documentType: String,
        uploadDate: Date,
        fileData: Data,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.documentType = documentType
        self.uploadDate = uploadDate
        self.fileData = fileData
        self.notes = notes
    }
}

enum DocumentType: String, CaseIterable {
    case bescheinigung = "Bescheinigung"
    case rechnung = "Rechnung"
    case schreiben = "Schreiben"
    case vertrag = "Vertrag"
    case sonstiges = "Sonstiges"

    var localizedName: String {
        switch self {
        case .bescheinigung: return String(localized: "document_type_bescheinigung")
        case .rechnung: return String(localized: "document_type_rechnung")
        case .schreiben: return String(localized: "document_type_schreiben")
        case .vertrag: return String(localized: "document_type_vertrag")
        case .sonstiges: return String(localized: "document_type_sonstiges")
        }
    }

    var icon: String {
        switch self {
        case .bescheinigung: return "checkmark.seal.fill"
        case .rechnung: return "doc.fill"
        case .schreiben: return "envelope.fill"
        case .vertrag: return "doc.richtext"
        case .sonstiges: return "doc.fill"
        }
    }
}

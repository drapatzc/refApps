import SwiftData
import Foundation

@Model
final class EmailAddress {
    var id: UUID
    var email: String
    var emailType: String
    var isPrimary: Bool
    var person: InsuredPerson?

    init(
        id: UUID = UUID(),
        email: String,
        emailType: String = EmailType.personal.rawValue,
        isPrimary: Bool = false
    ) {
        self.id = id
        self.email = email
        self.emailType = emailType
        self.isPrimary = isPrimary
    }
}

enum EmailType: String, CaseIterable {
    case personal = "Privat"
    case work = "Arbeit"
    case other = "Sonstige"

    var localizedName: String {
        switch self {
        case .personal: String(localized: "email_type_personal")
        case .work: String(localized: "email_type_work")
        case .other: String(localized: "email_type_other")
        }
    }

    var icon: String {
        switch self {
        case .personal: "envelope.fill"
        case .work: "briefcase.fill"
        case .other: "envelope.badge.fill"
        }
    }
}

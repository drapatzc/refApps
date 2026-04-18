import SwiftData
import Foundation

/// A SwiftData model representing an email address linked to an `InsuredPerson`.
@Model
final class EmailAddress {

    /// A unique, stable identifier for this email address.
    var id: UUID

    /// The email address string.
    var email: String

    /// The raw string value of the `EmailType` case (e.g. `"Privat"`).
    var emailType: String

    /// Whether this is the person's primary email address.
    var isPrimary: Bool

    /// The `InsuredPerson` this email address belongs to.
    var person: InsuredPerson?

    /// Creates a new email address record.
    ///
    /// - Parameters:
    ///   - id: A unique identifier; defaults to a new `UUID`.
    ///   - email: The email address string.
    ///   - emailType: The raw value of `EmailType`; defaults to `EmailType.personal.rawValue`.
    ///   - isPrimary: Whether this is the primary email address; defaults to `false`.
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

/// The category of an email address.
enum EmailType: String, CaseIterable {

    /// A personal or private email address.
    case personal = "Privat"

    /// A workplace email address.
    case work = "Arbeit"

    /// Any other type of email address.
    case other = "Sonstige"

    /// A localized display name sourced from the app's string catalog.
    var localizedName: String {
        switch self {
        case .personal: String(localized: "email_type_personal")
        case .work: String(localized: "email_type_work")
        case .other: String(localized: "email_type_other")
        }
    }

    /// The SF Symbols name for this email type.
    var icon: String {
        switch self {
        case .personal: "envelope.fill"
        case .work: "building.2.fill"
        case .other: "envelope.badge.fill"
        }
    }
}

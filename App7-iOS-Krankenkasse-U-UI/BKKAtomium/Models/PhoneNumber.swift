import SwiftData
import Foundation

/// A SwiftData model representing a phone number linked to an `InsuredPerson`.
@Model
final class PhoneNumber {

    /// A unique, stable identifier for this phone number.
    var id: UUID

    /// The phone number string, including optional country code and formatting characters.
    var number: String

    /// The raw string value of the `PhoneType` case (e.g. `"Mobil"`).
    var phoneType: String

    /// Whether this is the person's primary phone number.
    var isPrimary: Bool

    /// The `InsuredPerson` this phone number belongs to.
    var person: InsuredPerson?

    /// Creates a new phone number record.
    ///
    /// - Parameters:
    ///   - id: A unique identifier; defaults to a new `UUID`.
    ///   - number: The phone number string.
    ///   - phoneType: The raw value of `PhoneType`; defaults to `PhoneType.mobile.rawValue`.
    ///   - isPrimary: Whether this is the primary phone number; defaults to `false`.
    init(
        id: UUID = UUID(),
        number: String,
        phoneType: String = PhoneType.mobile.rawValue,
        isPrimary: Bool = false
    ) {
        self.id = id
        self.number = number
        self.phoneType = phoneType
        self.isPrimary = isPrimary
    }
}

/// The category of a phone number.
enum PhoneType: String, CaseIterable {

    /// A mobile phone number.
    case mobile = "Mobil"

    /// A landline number.
    case landline = "Festnetz"

    /// A workplace number.
    case work = "Arbeit"

    /// A fax number.
    case fax = "Fax"

    /// A localized display name sourced from the app's string catalog.
    var localizedName: String {
        switch self {
        case .mobile: String(localized: "phone_type_mobile")
        case .landline: String(localized: "phone_type_landline")
        case .work: String(localized: "phone_type_work")
        case .fax: String(localized: "phone_type_fax")
        }
    }

    /// The SF Symbols name for this phone type.
    var icon: String {
        switch self {
        case .mobile: "iphone"
        case .landline: "phone.fill"
        case .work: "building.2.fill"
        case .fax: "printer.fill"
        }
    }
}

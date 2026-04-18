import SwiftData
import Foundation

/// A SwiftData model representing a postal address linked to an `InsuredPerson`.
@Model
final class Address {

    /// A unique, stable identifier for this address.
    var id: UUID

    /// The street name.
    var street: String

    /// The house or building number.
    var houseNumber: String

    /// The postal code.
    var postalCode: String

    /// The city name.
    var city: String

    /// The country name.
    var country: String

    /// The raw string value of the `AddressType` case (e.g. `"Hauptwohnsitz"`).
    var addressType: String

    /// Whether this address is the person's primary address.
    var isPrimary: Bool

    /// The `InsuredPerson` this address belongs to.
    var person: InsuredPerson?

    /// A multi-line formatted address string containing street, postal code, city, and country.
    var formattedAddress: String {
        "\(street) \(houseNumber)\n\(postalCode) \(city)\n\(country)"
    }

    /// A single-line address summary suitable for labels and accessibility strings.
    var singleLineAddress: String {
        "\(street) \(houseNumber), \(postalCode) \(city)"
    }

    /// Creates a new address record.
    ///
    /// - Parameters:
    ///   - id: A unique identifier; defaults to a new `UUID`.
    ///   - street: The street name.
    ///   - houseNumber: The house or building number.
    ///   - postalCode: The postal code.
    ///   - city: The city name.
    ///   - country: The country; defaults to `"Deutschland"`.
    ///   - addressType: The raw value of `AddressType`; defaults to `AddressType.primary.rawValue`.
    ///   - isPrimary: Whether this is the primary address; defaults to `false`.
    init(
        id: UUID = UUID(),
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String = "Deutschland",
        addressType: String = AddressType.primary.rawValue,
        isPrimary: Bool = false
    ) {
        self.id = id
        self.street = street
        self.houseNumber = houseNumber
        self.postalCode = postalCode
        self.city = city
        self.country = country
        self.addressType = addressType
        self.isPrimary = isPrimary
    }
}

/// The category of a postal address.
enum AddressType: String, CaseIterable {

    /// The main registered residence (*Hauptwohnsitz*).
    case primary = "Hauptwohnsitz"

    /// A secondary residence (*Nebenwohnsitz*).
    case secondary = "Nebenwohnsitz"

    /// A workplace address.
    case work = "Arbeit"

    /// A localized display name sourced from the app's string catalog.
    var localizedName: String {
        switch self {
        case .primary: String(localized: "address_type_primary")
        case .secondary: String(localized: "address_type_secondary")
        case .work: String(localized: "address_type_work")
        }
    }
}

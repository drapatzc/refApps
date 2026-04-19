import SwiftData
import Foundation

@Model
final class Address {
    var id: UUID
    var street: String
    var houseNumber: String
    var postalCode: String
    var city: String
    var country: String
    var addressType: String
    var isPrimary: Bool
    var person: InsuredPerson?

    var formattedAddress: String {
        "\(street) \(houseNumber)\n\(postalCode) \(city)\n\(country)"
    }

    var singleLineAddress: String {
        "\(street) \(houseNumber), \(postalCode) \(city)"
    }

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

enum AddressType: String, CaseIterable {
    case primary = "Hauptwohnsitz"
    case secondary = "Nebenwohnsitz"
    case work = "Arbeit"

    var localizedName: String {
        switch self {
        case .primary: String(localized: "address_type_primary")
        case .secondary: String(localized: "address_type_secondary")
        case .work: String(localized: "address_type_work")
        }
    }

    var icon: String {
        switch self {
        case .primary: "house.fill"
        case .secondary: "building.2.fill"
        case .work: "briefcase.fill"
        }
    }
}

import Foundation

/// Salutation
enum Salutation: String, CaseIterable, Codable, Identifiable {
    case mr = "mr"
    case ms = "ms"
    case mx = "mx"

    var id: String { rawValue }

    var localizedLabel: String {
        switch self {
        case .mr: return String(localized: "salutation_mr")
        case .ms: return String(localized: "salutation_ms")
        case .mx: return String(localized: "salutation_mx")
        }
    }
}

/// User data model
struct User: Identifiable, Codable, Equatable, Hashable {
    var id: Int64
    var salutation: Salutation
    var firstName: String
    var lastName: String
    var street: String
    var houseNumber: String
    var postalCode: String
    var city: String
    var country: String
    var email: String

    init(
        id: Int64 = 0,
        salutation: Salutation,
        firstName: String,
        lastName: String,
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        email: String = ""
    ) {
        self.id = id
        self.salutation = salutation
        self.firstName = firstName
        self.lastName = lastName
        self.street = street
        self.houseNumber = houseNumber
        self.postalCode = postalCode
        self.city = city
        self.country = country
        self.email = email
    }

    /// Full name (salutation + first name + last name)
    var fullName: String {
        "\(salutation.localizedLabel) \(firstName) \(lastName)"
    }

    /// Formatted address
    var formattedAddress: String {
        "\(street) \(houseNumber), \(postalCode) \(city), \(country)"
    }
}

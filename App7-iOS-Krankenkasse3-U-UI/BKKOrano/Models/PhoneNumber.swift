import SwiftData
import Foundation

@Model
final class PhoneNumber {
    var id: UUID
    var number: String
    var phoneType: String
    var isPrimary: Bool
    var person: InsuredPerson?

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

enum PhoneType: String, CaseIterable {
    case mobile = "Mobil"
    case landline = "Festnetz"
    case work = "Arbeit"
    case fax = "Fax"

    var localizedName: String {
        switch self {
        case .mobile: String(localized: "phone_type_mobile")
        case .landline: String(localized: "phone_type_landline")
        case .work: String(localized: "phone_type_work")
        case .fax: String(localized: "phone_type_fax")
        }
    }

    var icon: String {
        switch self {
        case .mobile: "iphone"
        case .landline: "phone.fill"
        case .work: "briefcase.fill"
        case .fax: "printer.fill"
        }
    }
}

import SwiftData
import SwiftUI
import Foundation

@Model final class Invoice {
    var id: UUID = UUID()
    var date: Date
    var amount: Double
    var provider: String
    var category: String
    var status: String
    var invoiceDescription: String?

    @Relationship(deleteRule: .nullify)
    var person: InsuredPerson?

    init(
        id: UUID = UUID(),
        date: Date,
        amount: Double,
        provider: String,
        category: String,
        status: String,
        invoiceDescription: String? = nil
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.provider = provider
        self.category = category
        self.status = status
        self.invoiceDescription = invoiceDescription
    }
}

enum InvoiceCategory: String, CaseIterable {
    case arzt = "Arzt"
    case zahnarzt = "Zahnarzt"
    case medikament = "Medikament"
    case krankenhaus = "Krankenhaus"
    case sonstiges = "Sonstiges"

    var localizedName: String {
        switch self {
        case .arzt: return String(localized: "invoice_category_arzt")
        case .zahnarzt: return String(localized: "invoice_category_zahnarzt")
        case .medikament: return String(localized: "invoice_category_medikament")
        case .krankenhaus: return String(localized: "invoice_category_krankenhaus")
        case .sonstiges: return String(localized: "invoice_category_sonstiges")
        }
    }

    var icon: String {
        switch self {
        case .arzt: return "stethoscope"
        case .zahnarzt: return "tooth.fill"
        case .medikament: return "pills.fill"
        case .krankenhaus: return "cross.fill"
        case .sonstiges: return "doc.fill"
        }
    }
}

enum InvoiceStatus: String, CaseIterable {
    case offen = "offen"
    case erstattet = "erstattet"

    var localizedName: String {
        switch self {
        case .offen: return String(localized: "invoice_status_offen")
        case .erstattet: return String(localized: "invoice_status_erstattet")
        }
    }

    var color: Color {
        switch self {
        case .offen: return .orange
        case .erstattet: return .green
        }
    }
}

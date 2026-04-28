import SwiftData
import SwiftUI
import Foundation

@Model final class BenefitRequest {
    var id: UUID = UUID()
    var requestType: String
    var status: String
    var submittedDate: Date
    var processedDate: Date?
    var amount: Double?
    var requestDescription: String

    @Relationship(deleteRule: .nullify)
    var person: InsuredPerson?

    init(
        id: UUID = UUID(),
        requestType: String,
        status: String,
        submittedDate: Date,
        processedDate: Date? = nil,
        amount: Double? = nil,
        requestDescription: String
    ) {
        self.id = id
        self.requestType = requestType
        self.status = status
        self.submittedDate = submittedDate
        self.processedDate = processedDate
        self.amount = amount
        self.requestDescription = requestDescription
    }
}

enum BenefitRequestType: String, CaseIterable {
    case krankengeldantrag = "Krankengeldantrag"
    case kostenerstattung = "Kostenerstattung"
    case haushaltshilfe = "Haushaltshilfe"
    case mutterschaftsgeld = "Mutterschaftsgeld"
    case zahnersatz = "Zahnersatz"
    case hilfsmittel = "Hilfsmittel"
    case rehabilitation = "Rehabilitation"
    case sonstiges = "Sonstiges"

    var localizedName: String {
        switch self {
        case .krankengeldantrag: return String(localized: "benefit_type_krankengeldantrag")
        case .kostenerstattung: return String(localized: "benefit_type_kostenerstattung")
        case .haushaltshilfe: return String(localized: "benefit_type_haushaltshilfe")
        case .mutterschaftsgeld: return String(localized: "benefit_type_mutterschaftsgeld")
        case .zahnersatz: return String(localized: "benefit_type_zahnersatz")
        case .hilfsmittel: return String(localized: "benefit_type_hilfsmittel")
        case .rehabilitation: return String(localized: "benefit_type_rehabilitation")
        case .sonstiges: return String(localized: "benefit_type_sonstiges")
        }
    }

    var icon: String {
        switch self {
        case .krankengeldantrag: return "heart.text.square.fill"
        case .kostenerstattung: return "dollarsign.square.fill"
        case .haushaltshilfe: return "figure.walk"
        case .mutterschaftsgeld: return "heart.fill"
        case .zahnersatz: return "tooth.fill"
        case .hilfsmittel: return "medical.thermometer"
        case .rehabilitation: return "figure.walk"
        case .sonstiges: return "questionmark.square.fill"
        }
    }
}

enum BenefitRequestStatus: String, CaseIterable {
    case eingereicht = "eingereicht"
    case inBearbeitung = "inBearbeitung"
    case genehmigt = "genehmigt"
    case abgelehnt = "abgelehnt"

    var localizedName: String {
        switch self {
        case .eingereicht: return String(localized: "benefit_status_eingereicht")
        case .inBearbeitung: return String(localized: "benefit_status_inBearbeitung")
        case .genehmigt: return String(localized: "benefit_status_genehmigt")
        case .abgelehnt: return String(localized: "benefit_status_abgelehnt")
        }
    }

    var color: Color {
        switch self {
        case .eingereicht: return .blue
        case .inBearbeitung: return .orange
        case .genehmigt: return .green
        case .abgelehnt: return .red
        }
    }

    var icon: String {
        switch self {
        case .eingereicht: return "checkmark.circle.fill"
        case .inBearbeitung: return "hourglass.fill"
        case .genehmigt: return "checkmark.circle.fill"
        case .abgelehnt: return "xmark.circle.fill"
        }
    }
}

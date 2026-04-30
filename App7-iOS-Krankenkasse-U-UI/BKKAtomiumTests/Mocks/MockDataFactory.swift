import Foundation
import SwiftData
@testable import BKKAtomium

/// Zentrale Fabrik für Testdaten.
///
/// `MockDataFactory` stellt vorkonfigurierte SwiftData-Objekte bereit,
/// die in Unit-Tests als Eingabedaten oder erwartete Rückgabewerte verwendet werden.
///
/// **Verantwortung:** Vermeidet duplizierte Testdaten-Erstellung in Test-Dateien.
/// Alle Testdaten sollen hier zentral definiert sein.
///
/// **Verwendung:**
/// ```swift
/// let person = MockDataFactory.makeInsuredPerson()
/// let addresses = MockDataFactory.makeAddresses(count: 3, for: person)
/// ```
enum MockDataFactory {

    // MARK: - InsuredPerson

    /// Erstellt eine `InsuredPerson` mit Standardwerten.
    ///
    /// - Parameters:
    ///   - firstName: Vorname; Standard: "Max".
    ///   - lastName: Nachname; Standard: "Mustermann".
    ///   - insuranceNumber: Versicherungsnummer; Standard: "A123456789".
    /// - Returns: Eine neue `InsuredPerson`-Instanz.
    static func makeInsuredPerson(
        firstName: String = "Max",
        lastName: String = "Mustermann",
        insuranceNumber: String = "A123456789"
    ) -> InsuredPerson {
        InsuredPerson(
            lastName: lastName,
            firstName: firstName,
            birthDate: Calendar.current.date(
                from: DateComponents(year: 1985, month: 3, day: 22)
            ) ?? Date(),
            insuranceNumber: insuranceNumber,
            pensionInsuranceNumber: "12 345678 A 001",
            taxId: "12345678901"
        )
    }

    // MARK: - Address

    /// Erstellt eine primäre Hauptadresse in Essen.
    static func makeAddress(
        street: String = "Hauptstraße",
        houseNumber: String = "1",
        postalCode: String = "45127",
        city: String = "Essen",
        isPrimary: Bool = true
    ) -> Address {
        Address(
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: "Deutschland",
            addressType: AddressType.primary.rawValue,
            isPrimary: isPrimary
        )
    }

    /// Erstellt `count` Adressen für eine Person.
    static func makeAddresses(count: Int, for person: InsuredPerson) -> [Address] {
        (0..<count).map { index in
            Address(
                street: "Teststraße",
                houseNumber: "\(index + 1)",
                postalCode: "10115",
                city: "Berlin",
                country: "Deutschland",
                addressType: index == 0 ? AddressType.primary.rawValue : AddressType.secondary.rawValue,
                isPrimary: index == 0
            )
        }
    }

    // MARK: - Invoice

    /// Erstellt eine Beispiel-Rechnung.
    static func makeInvoice(
        amount: Double = 120.50,
        provider: String = "Arztpraxis Muster",
        category: InvoiceCategory = .arzt,
        status: InvoiceStatus = .offen,
        date: Date = Date()
    ) -> Invoice {
        Invoice(
            date: date,
            amount: amount,
            provider: provider,
            category: category.rawValue,
            status: status.rawValue,
            invoiceDescription: "Testrechnung"
        )
    }

    /// Erstellt `count` Rechnungen mit gemischten Werten.
    static func makeInvoices(count: Int) -> [Invoice] {
        let categories: [InvoiceCategory] = [.arzt, .zahnarzt, .medikament, .krankenhaus, .sonstiges]
        let statuses: [InvoiceStatus] = [.offen, .erstattet]
        return (0..<count).map { index in
            Invoice(
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                amount: Double(index + 1) * 25.0,
                provider: "Anbieter \(index + 1)",
                category: categories[index % categories.count].rawValue,
                status: statuses[index % statuses.count].rawValue,
                invoiceDescription: nil
            )
        }
    }

    // MARK: - BenefitRequest

    /// Erstellt einen Beispiel-Leistungsantrag.
    static func makeBenefitRequest(
        requestType: BenefitRequestType = .kostenerstattung,
        status: BenefitRequestStatus = .eingereicht,
        amount: Double? = 150.0
    ) -> BenefitRequest {
        BenefitRequest(
            requestType: requestType.rawValue,
            status: status.rawValue,
            submittedDate: Date(),
            amount: amount,
            requestDescription: "Testantrag"
        )
    }

    // MARK: - AppThemeModel

    /// Erstellt ein minimales Test-Theme ohne Bundle-Zugriff.
    static func makeTheme(name: String = "test") -> AppThemeModel {
        AppThemeModel(
            name: name,
            displayName: "Test Theme",
            primaryHex: "#1C4A80",
            accentHex: "#1A613D",
            gradientStartHex: "#14386B",
            gradientEndHex: "#1A6147",
            headerGradientStartHex: "#0F2E5C",
            headerGradientEndHex: "#174D38",
            primaryDarkHex: "#4A7AB5",
            accentDarkHex: "#3A9463",
            successHex: "#34C759",
            warningHex: "#FF9500",
            errorHex: "#FF3B30",
            cornerRadiusS: 8,
            cornerRadiusM: 12,
            cornerRadiusL: 16,
            cornerRadiusXL: 20,
            spacingXS: 4,
            spacingS: 8,
            spacingM: 16,
            spacingL: 24,
            spacingXL: 32,
            spacingXXL: 48,
            fontSizeCaption: 12,
            fontSizeBody: 16,
            fontSizeTitle: 22,
            fontSizeHeadline: 28
        )
    }
}

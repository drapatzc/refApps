import SwiftData
import Foundation

/// A namespace for seeding the SwiftData store with a single demo insured person.
///
/// The seeder is designed to be idempotent — it checks whether any `InsuredPerson`
/// record already exists and skips seeding if one is found.
enum MockDataSeeder {

    /// Seeds the store with demo data if it is currently empty.
    ///
    /// The fetch-count check runs off the main actor; the actual insert is
    /// dispatched to the main actor via `seed(context:)`.
    ///
    /// - Parameter context: The `ModelContext` to insert data into.
    static func seedIfNeeded(context: ModelContext) async {
        let descriptor = FetchDescriptor<InsuredPerson>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        await MainActor.run {
            seed(context: context)
        }
    }

    /// Inserts a fully populated demo person (Christian Drapatz) with one address,
    /// one phone number, one bank account, and two email addresses.
    ///
    /// Must be called on the main actor because `ModelContext` is not `Sendable`.
    ///
    /// - Parameter context: The `ModelContext` to insert data into.
    @MainActor
    static func seed(context: ModelContext) {
        let calendar = Calendar.current
        let birthDate = calendar.date(from: DateComponents(year: 1985, month: 3, day: 22))!

        let person = InsuredPerson(
            lastName: "Drapatz",
            firstName: "Christian",
            birthDate: birthDate,
            insuranceNumber: "A987654321",
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        context.insert(person)

        // Adressen (alle Typen mit mehreren Beispielen)
        let addresses: [Address] = [
            // Hauptwohnsitz
            Address(
                street: "Am Mühlenbach",
                houseNumber: "105",
                postalCode: "45147",
                city: "Essen",
                country: "Deutschland",
                addressType: AddressType.primary.rawValue,
                isPrimary: true
            ),
            // Nebenw ohnsitz 1
            Address(
                street: "Königstraße",
                houseNumber: "42",
                postalCode: "40211",
                city: "Düsseldorf",
                country: "Deutschland",
                addressType: AddressType.secondary.rawValue,
                isPrimary: false
            ),
            // Nebenwohnsitz 2
            Address(
                street: "Seestraße",
                houseNumber: "15",
                postalCode: "20148",
                city: "Hamburg",
                country: "Deutschland",
                addressType: AddressType.secondary.rawValue,
                isPrimary: false
            ),
            // Arbeit 1
            Address(
                street: "Handelsblattstraße",
                houseNumber: "1",
                postalCode: "40002",
                city: "Düsseldorf",
                country: "Deutschland",
                addressType: AddressType.work.rawValue,
                isPrimary: false
            ),
            // Arbeit 2
            Address(
                street: "Unter den Linden",
                houseNumber: "77",
                postalCode: "10117",
                city: "Berlin",
                country: "Deutschland",
                addressType: AddressType.work.rawValue,
                isPrimary: false
            )
        ]
        person.addresses.append(contentsOf: addresses)

        // Rufnummern (alle Typen mit mehreren Beispielen)
        let phoneNumbers: [PhoneNumber] = [
            // Mobil 1 (Hauptnummer)
            PhoneNumber(
                number: "+49 170 9876543",
                phoneType: PhoneType.mobile.rawValue,
                isPrimary: true
            ),
            // Mobil 2
            PhoneNumber(
                number: "+49 172 1234567",
                phoneType: PhoneType.mobile.rawValue,
                isPrimary: false
            ),
            // Festnetz Essen
            PhoneNumber(
                number: "+49 201 12345",
                phoneType: PhoneType.landline.rawValue,
                isPrimary: false
            ),
            // Festnetz Hamburg
            PhoneNumber(
                number: "+49 40 54321098",
                phoneType: PhoneType.landline.rawValue,
                isPrimary: false
            ),
            // Arbeit Düsseldorf
            PhoneNumber(
                number: "+49 211 87654321",
                phoneType: PhoneType.work.rawValue,
                isPrimary: false
            ),
            // Arbeit Berlin
            PhoneNumber(
                number: "+49 30 555123456",
                phoneType: PhoneType.work.rawValue,
                isPrimary: false
            ),
            // Fax Essen
            PhoneNumber(
                number: "+49 201 54321",
                phoneType: PhoneType.fax.rawValue,
                isPrimary: false
            ),
            // Fax Arbeit
            PhoneNumber(
                number: "+49 211 87654322",
                phoneType: PhoneType.fax.rawValue,
                isPrimary: false
            )
        ]
        person.phoneNumbers.append(contentsOf: phoneNumbers)

        // Bankverbindungen (mehrere)
        let bankAccounts: [BankAccount] = [
            // Hauptkonto Commerzbank
            BankAccount(
                iban: "DE89370400440532013000",
                bic: "COBADEFFXXX",
                bankName: "Commerzbank AG",
                accountHolder: "Christian Drapatz",
                isPrimary: true
            ),
            // Girokonto Deutsche Bank
            BankAccount(
                iban: "DE91100000000123456789",
                bic: "SOGEDEFF",
                bankName: "Deutsche Bank",
                accountHolder: "Christian Drapatz",
                isPrimary: false
            ),
            // Sparkonto ING-DiBa
            BankAccount(
                iban: "DE75512108001234567890",
                bic: "INGDDEDD",
                bankName: "ING-DiBa AG",
                accountHolder: "Christian Drapatz",
                isPrimary: false
            ),
            // Geschäftskonto Berliner Bank
            BankAccount(
                iban: "DE68120300000111222333",
                bic: "DEUTDEDD",
                bankName: "Berliner Bank",
                accountHolder: "Christian Drapatz",
                isPrimary: false
            )
        ]
        person.bankAccounts.append(contentsOf: bankAccounts)

        // E-Mail (alle Typen mit mehreren Beispielen)
        let emailAddresses: [EmailAddress] = [
            // Privat 1 (Hauptadresse)
            EmailAddress(
                email: "c.drapatz@gmx.de",
                emailType: EmailType.personal.rawValue,
                isPrimary: true
            ),
            // Privat 2
            EmailAddress(
                email: "christian.drapatz@web.de",
                emailType: EmailType.personal.rawValue,
                isPrimary: false
            ),
            // Arbeit Handelsblatt
            EmailAddress(
                email: "c.drapatz@handelsblatt.de",
                emailType: EmailType.work.rawValue,
                isPrimary: false
            ),
            // Arbeit Berlin
            EmailAddress(
                email: "christian.drapatz@berlin-office.de",
                emailType: EmailType.work.rawValue,
                isPrimary: false
            ),
            // Sonstige (Outlook)
            EmailAddress(
                email: "drapatz@outlook.com",
                emailType: EmailType.other.rawValue,
                isPrimary: false
            ),
            // Sonstige (LinkedIn/Xing)
            EmailAddress(
                email: "contact@drapatz-profile.de",
                emailType: EmailType.other.rawValue,
                isPrimary: false
            )
        ]
        person.emailAddresses.append(contentsOf: emailAddresses)

        // Rechnungen (verschiedene Kategorien und Status)
        let invoices: [Invoice] = [
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!,
                amount: 10.00,
                provider: "Dr. Müller",
                category: InvoiceCategory.arzt.rawValue,
                status: InvoiceStatus.erstattet.rawValue,
                invoiceDescription: "Allgemeine Untersuchung"
            ),
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 2, day: 3))!,
                amount: 85.50,
                provider: "Zahnarzt Schmidt",
                category: InvoiceCategory.zahnarzt.rawValue,
                status: InvoiceStatus.offen.rawValue,
                invoiceDescription: "Zahnreinigung und Kontrolle"
            ),
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!,
                amount: 25.00,
                provider: "Apotheke am Markt",
                category: InvoiceCategory.medikament.rawValue,
                status: InvoiceStatus.erstattet.rawValue,
                invoiceDescription: "Verschriebene Medikamente"
            ),
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 3, day: 5))!,
                amount: 320.00,
                provider: "St. Ludwigs Krankenhaus",
                category: InvoiceCategory.krankenhaus.rawValue,
                status: InvoiceStatus.offen.rawValue,
                invoiceDescription: "Stationäre Aufnahme (3 Tage)"
            ),
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 3, day: 20))!,
                amount: 15.99,
                provider: "Sanitätshalle Leipzig",
                category: InvoiceCategory.sonstiges.rawValue,
                status: InvoiceStatus.erstattet.rawValue,
                invoiceDescription: "Orthopädische Einlagen"
            ),
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 4, day: 5))!,
                amount: 45.00,
                provider: "Dr. Schneider - Augenarzt",
                category: InvoiceCategory.arzt.rawValue,
                status: InvoiceStatus.offen.rawValue,
                invoiceDescription: "Augenuntersuchung und neue Brille"
            ),
            Invoice(
                date: calendar.date(from: DateComponents(year: 2026, month: 4, day: 12))!,
                amount: 120.00,
                provider: "Physio-Praxis Meyer",
                category: InvoiceCategory.sonstiges.rawValue,
                status: InvoiceStatus.erstattet.rawValue,
                invoiceDescription: "10 Sitzungen Physiotherapie"
            )
        ]
        invoices.forEach { person.invoices.append($0) }

        // Leistungsanträge (verschiedene Typen und Status)
        let benefitRequests: [BenefitRequest] = [
            BenefitRequest(
                requestType: BenefitRequestType.krankengeldantrag.rawValue,
                status: BenefitRequestStatus.eingereicht.rawValue,
                submittedDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 20))!,
                amount: nil,
                requestDescription: "Krankengeldantrag für Behandlungszeit 15.01. - 20.01.2026"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.kostenerstattung.rawValue,
                status: BenefitRequestStatus.genehmigt.rawValue,
                submittedDate: calendar.date(from: DateComponents(year: 2026, month: 2, day: 1))!,
                processedDate: calendar.date(from: DateComponents(year: 2026, month: 2, day: 15))!,
                amount: 85.50,
                requestDescription: "Kostenerstattung für Zahnarztbehandlung"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.hilfsmittel.rawValue,
                status: BenefitRequestStatus.inBearbeitung.rawValue,
                submittedDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!,
                amount: 450.00,
                requestDescription: "Antrag auf Kostenübernahme für orthopädische Schuhe"
            )
        ]
        benefitRequests.forEach { person.benefitRequests.append($0) }

        // Dokumente (verschiedene Typen)
        let bescheinigung = "Arztbescheinigung zur Vorlage bei Behörden".data(using: .utf8) ?? Data()
        let rechnung = "Rechnung für Zahnarztbehandlung".data(using: .utf8) ?? Data()

        let documents: [InsuranceDocument] = [
            InsuranceDocument(
                title: "Ärztliche Bescheinigung Januar 2026",
                documentType: DocumentType.bescheinigung.rawValue,
                uploadDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 25))!,
                fileData: bescheinigung,
                notes: "Für Arbeitgeber"
            ),
            InsuranceDocument(
                title: "Zahnarztrechnung Februar 2026",
                documentType: DocumentType.rechnung.rawValue,
                uploadDate: calendar.date(from: DateComponents(year: 2026, month: 2, day: 5))!,
                fileData: rechnung,
                notes: nil
            ),
            InsuranceDocument(
                title: "Arztbericht März 2026",
                documentType: DocumentType.bericht.rawValue,
                uploadDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!,
                fileData: bescheinigung,
                notes: "Kardiologie"
            ),
            InsuranceDocument(
                title: "Laborergebnis April 2026",
                documentType: DocumentType.bescheinigung.rawValue,
                uploadDate: calendar.date(from: DateComponents(year: 2026, month: 4, day: 2))!,
                fileData: rechnung,
                notes: nil
            )
        ]
        documents.forEach { person.documents.append($0) }

        try? context.save()
    }
}

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

    /// Inserts a fully populated demo person (Christian Drapatz) with addresses,
    /// phone numbers, bank accounts, emails, 17 invoices (spanning 12 months),
    /// 6 benefit requests, and 7 documents.
    ///
    /// Must be called on the main actor because `ModelContext` is not `Sendable`.
    ///
    /// - Parameter context: The `ModelContext` to insert data into.
    @MainActor
    static func seed(context: ModelContext) {
        let calendar = Calendar.current
        let birthDate = calendar.date(from: DateComponents(year: 1985, month: 3, day: 22))!

        func date(year: Int, month: Int, day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
        }

        let person = InsuredPerson(
            lastName: "Drapatz",
            firstName: "Christian",
            birthDate: birthDate,
            insuranceNumber: "A987654321",
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        context.insert(person)

        // MARK: Adressen
        let addresses: [Address] = [
            Address(street: "Am Mühlenbach", houseNumber: "105", postalCode: "45147", city: "Essen",
                    country: "Deutschland", addressType: AddressType.primary.rawValue, isPrimary: true),
            Address(street: "Königstraße", houseNumber: "42", postalCode: "40211", city: "Düsseldorf",
                    country: "Deutschland", addressType: AddressType.secondary.rawValue, isPrimary: false),
            Address(street: "Seestraße", houseNumber: "15", postalCode: "20148", city: "Hamburg",
                    country: "Deutschland", addressType: AddressType.secondary.rawValue, isPrimary: false),
            Address(street: "Handelsblattstraße", houseNumber: "1", postalCode: "40002", city: "Düsseldorf",
                    country: "Deutschland", addressType: AddressType.work.rawValue, isPrimary: false),
            Address(street: "Unter den Linden", houseNumber: "77", postalCode: "10117", city: "Berlin",
                    country: "Deutschland", addressType: AddressType.work.rawValue, isPrimary: false)
        ]
        person.addresses.append(contentsOf: addresses)

        // MARK: Rufnummern
        let phoneNumbers: [PhoneNumber] = [
            PhoneNumber(number: "+49 170 9876543", phoneType: PhoneType.mobile.rawValue, isPrimary: true),
            PhoneNumber(number: "+49 172 1234567", phoneType: PhoneType.mobile.rawValue, isPrimary: false),
            PhoneNumber(number: "+49 201 12345",   phoneType: PhoneType.landline.rawValue, isPrimary: false),
            PhoneNumber(number: "+49 40 54321098", phoneType: PhoneType.landline.rawValue, isPrimary: false),
            PhoneNumber(number: "+49 211 87654321", phoneType: PhoneType.work.rawValue, isPrimary: false),
            PhoneNumber(number: "+49 30 555123456", phoneType: PhoneType.work.rawValue, isPrimary: false),
            PhoneNumber(number: "+49 201 54321",   phoneType: PhoneType.fax.rawValue, isPrimary: false),
            PhoneNumber(number: "+49 211 87654322", phoneType: PhoneType.fax.rawValue, isPrimary: false)
        ]
        person.phoneNumbers.append(contentsOf: phoneNumbers)

        // MARK: Bankverbindungen
        let bankAccounts: [BankAccount] = [
            BankAccount(iban: "DE89370400440532013000", bic: "COBADEFFXXX", bankName: "Commerzbank AG",
                        accountHolder: "Christian Drapatz", isPrimary: true),
            BankAccount(iban: "DE91100000000123456789", bic: "SOGEDEFF", bankName: "Deutsche Bank",
                        accountHolder: "Christian Drapatz", isPrimary: false),
            BankAccount(iban: "DE75512108001234567890", bic: "INGDDEDD", bankName: "ING-DiBa AG",
                        accountHolder: "Christian Drapatz", isPrimary: false),
            BankAccount(iban: "DE68120300000111222333", bic: "DEUTDEDD", bankName: "Berliner Bank",
                        accountHolder: "Christian Drapatz", isPrimary: false)
        ]
        person.bankAccounts.append(contentsOf: bankAccounts)

        // MARK: E-Mail-Adressen
        let emailAddresses: [EmailAddress] = [
            EmailAddress(email: "c.drapatz@gmx.de", emailType: EmailType.personal.rawValue, isPrimary: true),
            EmailAddress(email: "christian.drapatz@web.de", emailType: EmailType.personal.rawValue, isPrimary: false),
            EmailAddress(email: "c.drapatz@handelsblatt.de", emailType: EmailType.work.rawValue, isPrimary: false),
            EmailAddress(email: "christian.drapatz@berlin-office.de", emailType: EmailType.work.rawValue, isPrimary: false),
            EmailAddress(email: "drapatz@outlook.com", emailType: EmailType.other.rawValue, isPrimary: false),
            EmailAddress(email: "contact@drapatz-profile.de", emailType: EmailType.other.rawValue, isPrimary: false)
        ]
        person.emailAddresses.append(contentsOf: emailAddresses)

        // MARK: Rechnungen – 17 Einträge über 12 Monate (Mai 2025 – Apr 2026)
        let invoices: [Invoice] = [
            Invoice(date: date(year: 2025, month: 5, day: 8),
                    amount: 90.00, provider: "Physio-Praxis Weber",
                    category: InvoiceCategory.sonstiges.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "10 Sitzungen Physiotherapie"),
            Invoice(date: date(year: 2025, month: 5, day: 22),
                    amount: 35.00, provider: "Dr. Vogel – Hausarzt",
                    category: InvoiceCategory.arzt.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Allgemeinuntersuchung"),
            Invoice(date: date(year: 2025, month: 6, day: 14),
                    amount: 55.00, provider: "Augenarzt Dr. Stern",
                    category: InvoiceCategory.arzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Sehtest und Brillenanpassung"),
            Invoice(date: date(year: 2025, month: 7, day: 3),
                    amount: 32.00, provider: "Apotheke Stadtmitte",
                    category: InvoiceCategory.medikament.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Verschriebene Medikamente"),
            Invoice(date: date(year: 2025, month: 8, day: 19),
                    amount: 48.00, provider: "Labor Dr. Schäfer",
                    category: InvoiceCategory.arzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Blutuntersuchung und Differenzialblutbild"),
            Invoice(date: date(year: 2025, month: 9, day: 11),
                    amount: 120.00, provider: "Orthopäde Dr. Braun",
                    category: InvoiceCategory.sonstiges.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Einlagenversorgung und Beratung"),
            Invoice(date: date(year: 2025, month: 10, day: 7),
                    amount: 85.50, provider: "Zahnarzt Dr. Klein",
                    category: InvoiceCategory.zahnarzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Zahnreinigung und Kontrolluntersuchung"),
            Invoice(date: date(year: 2025, month: 11, day: 25),
                    amount: 22.00, provider: "Apotheke am Markt",
                    category: InvoiceCategory.medikament.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Verschriebene Medikamente"),
            Invoice(date: date(year: 2025, month: 12, day: 3),
                    amount: 75.00, provider: "Dermatologe Dr. Bauer",
                    category: InvoiceCategory.arzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Hautscreening und Beratung"),
            Invoice(date: date(year: 2025, month: 12, day: 18),
                    amount: 280.00, provider: "Zahnarzt Dr. Klein",
                    category: InvoiceCategory.zahnarzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Zahnersatz – Keramik-Teilkrone"),
            Invoice(date: date(year: 2026, month: 1, day: 15),
                    amount: 10.00, provider: "Dr. Müller",
                    category: InvoiceCategory.arzt.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Allgemeine Untersuchung"),
            Invoice(date: date(year: 2026, month: 2, day: 3),
                    amount: 85.50, provider: "Zahnarzt Schmidt",
                    category: InvoiceCategory.zahnarzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Zahnreinigung und Kontrolle"),
            Invoice(date: date(year: 2026, month: 2, day: 10),
                    amount: 25.00, provider: "Apotheke am Markt",
                    category: InvoiceCategory.medikament.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Verschriebene Medikamente"),
            Invoice(date: date(year: 2026, month: 3, day: 5),
                    amount: 320.00, provider: "St. Ludwigs Krankenhaus",
                    category: InvoiceCategory.krankenhaus.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Stationäre Aufnahme (3 Tage)"),
            Invoice(date: date(year: 2026, month: 3, day: 20),
                    amount: 15.99, provider: "Sanitätshalle Leipzig",
                    category: InvoiceCategory.sonstiges.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "Orthopädische Einlagen"),
            Invoice(date: date(year: 2026, month: 4, day: 5),
                    amount: 45.00, provider: "Dr. Schneider – Augenarzt",
                    category: InvoiceCategory.arzt.rawValue,
                    status: InvoiceStatus.offen.rawValue,
                    invoiceDescription: "Augenuntersuchung und neue Brille"),
            Invoice(date: date(year: 2026, month: 4, day: 12),
                    amount: 120.00, provider: "Physio-Praxis Meyer",
                    category: InvoiceCategory.sonstiges.rawValue,
                    status: InvoiceStatus.erstattet.rawValue,
                    invoiceDescription: "10 Sitzungen Physiotherapie")
        ]
        invoices.forEach { person.invoices.append($0) }

        // MARK: Leistungsanträge – 6 Einträge mit allen Status-Varianten
        let benefitRequests: [BenefitRequest] = [
            BenefitRequest(
                requestType: BenefitRequestType.krankengeldantrag.rawValue,
                status: BenefitRequestStatus.eingereicht.rawValue,
                submittedDate: date(year: 2026, month: 1, day: 20),
                requestDescription: "Krankengeldantrag für Behandlungszeit 15.01. – 20.01.2026"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.kostenerstattung.rawValue,
                status: BenefitRequestStatus.genehmigt.rawValue,
                submittedDate: date(year: 2026, month: 2, day: 1),
                processedDate: date(year: 2026, month: 2, day: 15),
                amount: 85.50,
                requestDescription: "Kostenerstattung für Zahnarztbehandlung"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.hilfsmittel.rawValue,
                status: BenefitRequestStatus.inBearbeitung.rawValue,
                submittedDate: date(year: 2026, month: 3, day: 10),
                amount: 450.00,
                requestDescription: "Antrag auf Kostenübernahme für orthopädische Schuhe"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.rehabilitation.rawValue,
                status: BenefitRequestStatus.abgelehnt.rawValue,
                submittedDate: date(year: 2025, month: 9, day: 5),
                processedDate: date(year: 2025, month: 9, day: 25),
                requestDescription: "Antrag auf stationäre Rehabilitation (Rückenerkrankung)"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.zahnersatz.rawValue,
                status: BenefitRequestStatus.genehmigt.rawValue,
                submittedDate: date(year: 2025, month: 11, day: 12),
                processedDate: date(year: 2025, month: 12, day: 3),
                amount: 280.00,
                requestDescription: "Kostenübernahme Zahnersatz – Keramik-Teilkrone"
            ),
            BenefitRequest(
                requestType: BenefitRequestType.kostenerstattung.rawValue,
                status: BenefitRequestStatus.eingereicht.rawValue,
                submittedDate: date(year: 2026, month: 4, day: 14),
                amount: 320.00,
                requestDescription: "Kostenerstattung stationäre Aufnahme St. Ludwigs Krankenhaus"
            )
        ]
        benefitRequests.forEach { person.benefitRequests.append($0) }

        // MARK: Dokumente – 7 Einträge verschiedener Typen
        let fileData = "Dokument".data(using: .utf8) ?? Data()

        let documents: [InsuranceDocument] = [
            InsuranceDocument(title: "Ärztliche Bescheinigung Jan. 2026",
                              documentType: DocumentType.bescheinigung.rawValue,
                              uploadDate: date(year: 2026, month: 1, day: 25),
                              fileData: fileData, notes: "Für Arbeitgeber"),
            InsuranceDocument(title: "Zahnarztrechnung Feb. 2026",
                              documentType: DocumentType.rechnung.rawValue,
                              uploadDate: date(year: 2026, month: 2, day: 5),
                              fileData: fileData, notes: nil),
            InsuranceDocument(title: "Krankenhausentlassung März 2026",
                              documentType: DocumentType.bescheinigung.rawValue,
                              uploadDate: date(year: 2026, month: 3, day: 8),
                              fileData: fileData, notes: "St. Ludwigs Krankenhaus"),
            InsuranceDocument(title: "Arztbericht Kardiologie März 2026",
                              documentType: DocumentType.bescheinigung.rawValue,
                              uploadDate: date(year: 2026, month: 3, day: 10),
                              fileData: fileData, notes: "Kardiologie – Dr. Hartmann"),
            InsuranceDocument(title: "Laborergebnis Apr. 2026",
                              documentType: DocumentType.bescheinigung.rawValue,
                              uploadDate: date(year: 2026, month: 4, day: 2),
                              fileData: fileData, notes: nil),
            InsuranceDocument(title: "Physiotherapie-Verordnung Sep. 2025",
                              documentType: DocumentType.vertrag.rawValue,
                              uploadDate: date(year: 2025, month: 9, day: 11),
                              fileData: fileData, notes: "Dr. Braun – Rückentherapie"),
            InsuranceDocument(title: "Versicherungsnachweis 2025",
                              documentType: DocumentType.bescheinigung.rawValue,
                              uploadDate: date(year: 2025, month: 6, day: 1),
                              fileData: fileData, notes: nil)
        ]
        documents.forEach { person.documents.append($0) }

        try? context.save()
    }
}

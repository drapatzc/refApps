import Foundation
import SwiftData

// MARK: - AddressRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `Address`-Objekte einer versicherten Person.
///
/// **Verantwortung:** Definiert die Mindestschnittstelle für CRUD-Operationen
/// auf Adressen. Ermöglicht den Austausch der konkreten Implementierung durch
/// Mock-Objekte in Unit-Tests.
///
/// **Testbarkeit:** Alle ViewModels, die Adressen verwalten, nehmen dieses
/// Protokoll entgegen — nicht die konkrete Klasse.
protocol AddressRepositoryProtocol {

    /// Gibt alle Adressen einer Person zurück, sortiert nach Primärstatus und Stadt.
    func fetchAll(for person: InsuredPerson) -> [Address]

    /// Legt eine neue Adresse an und validiert die Eingaben.
    func add(
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        addressType: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws

    /// Aktualisiert eine bestehende Adresse.
    func update(
        _ address: Address,
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        addressType: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws

    /// Löscht eine Adresse aus der Persistenzschicht.
    func delete(_ address: Address) throws
}

// MARK: - PhoneRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `PhoneNumber`-Objekte einer versicherten Person.
protocol PhoneRepositoryProtocol {

    /// Gibt alle Telefonnummern einer Person zurück.
    func fetchAll(for person: InsuredPerson) -> [PhoneNumber]

    /// Legt eine neue Telefonnummer an und validiert die Eingaben.
    func add(
        number: String,
        phoneType: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws

    /// Aktualisiert eine bestehende Telefonnummer.
    func update(
        _ phone: PhoneNumber,
        number: String,
        phoneType: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws

    /// Löscht eine Telefonnummer aus der Persistenzschicht.
    func delete(_ phone: PhoneNumber) throws
}

// MARK: - EmailRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `EmailAddress`-Objekte einer versicherten Person.
protocol EmailRepositoryProtocol {

    /// Gibt alle E-Mail-Adressen einer Person zurück.
    func fetchAll(for person: InsuredPerson) -> [EmailAddress]

    /// Legt eine neue E-Mail-Adresse an und validiert die Eingaben.
    func add(
        email: String,
        emailType: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws

    /// Aktualisiert eine bestehende E-Mail-Adresse.
    func update(
        _ emailAddress: EmailAddress,
        email: String,
        emailType: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws

    /// Löscht eine E-Mail-Adresse aus der Persistenzschicht.
    func delete(_ emailAddress: EmailAddress) throws
}

// MARK: - BankAccountRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `BankAccount`-Objekte einer versicherten Person.
protocol BankAccountRepositoryProtocol {

    /// Gibt alle Bankkonten einer Person zurück.
    func fetchAll(for person: InsuredPerson) -> [BankAccount]

    /// Legt ein neues Bankkonto an und validiert die Eingaben.
    func add(
        iban: String,
        bic: String,
        bankName: String,
        accountHolder: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws

    /// Aktualisiert ein bestehendes Bankkonto.
    func update(
        _ account: BankAccount,
        iban: String,
        bic: String,
        bankName: String,
        accountHolder: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws

    /// Löscht ein Bankkonto aus der Persistenzschicht.
    func delete(_ account: BankAccount) throws
}

// MARK: - InvoiceRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `Invoice`-Objekte einer versicherten Person.
protocol InvoiceRepositoryProtocol {

    /// Gibt alle Rechnungen einer Person zurück, sortiert nach Datum (neueste zuerst).
    func fetchAll(for person: InsuredPerson) -> [Invoice]

    /// Gibt gefilterte Rechnungen zurück.
    func fetchFiltered(
        for person: InsuredPerson,
        category: InvoiceCategory?,
        status: InvoiceStatus?
    ) -> [Invoice]

    /// Legt eine neue Rechnung an und validiert die Eingaben.
    func add(
        date: Date,
        amount: Double,
        provider: String,
        category: String,
        status: String,
        description: String?,
        to person: InsuredPerson
    ) throws

    /// Löscht eine Rechnung aus der Persistenzschicht.
    func delete(_ invoice: Invoice) throws
}

// MARK: - DocumentRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `InsuranceDocument`-Objekte einer versicherten Person.
protocol DocumentRepositoryProtocol {

    /// Gibt alle Dokumente einer Person zurück, sortiert nach Upload-Datum (neuestes zuerst).
    func fetchAll(for person: InsuredPerson) -> [InsuranceDocument]

    /// Legt ein neues Dokument an und validiert die Eingaben.
    func add(
        title: String,
        documentType: String,
        fileData: Data,
        notes: String?,
        to person: InsuredPerson
    ) throws

    /// Löscht ein Dokument aus der Persistenzschicht.
    func delete(_ document: InsuranceDocument) throws
}

// MARK: - BenefitRequestRepositoryProtocol

/// Abstrahiert den Datenzugriff auf `BenefitRequest`-Objekte einer versicherten Person.
protocol BenefitRequestRepositoryProtocol {

    /// Gibt alle Leistungsanträge einer Person zurück, sortiert nach Antragsdatum.
    func fetchAll(for person: InsuredPerson) -> [BenefitRequest]

    /// Legt einen neuen Leistungsantrag an und validiert die Eingaben.
    func add(
        requestType: String,
        description: String,
        amount: Double?,
        to person: InsuredPerson
    ) throws

    /// Aktualisiert den Status eines Leistungsantrags.
    func updateStatus(_ request: BenefitRequest, status: BenefitRequestStatus) throws

    /// Löscht einen Leistungsantrag aus der Persistenzschicht.
    func delete(_ request: BenefitRequest) throws
}

// MARK: - AuthServiceProtocol

/// Abstrahiert den Authentifizierungsdienst für die App.
///
/// **Verantwortung:** Definiert die Mindestschnittstelle für passwort- und
/// biometriebasierte Authentifizierung. Ermöglicht die Verwendung von
/// Mock-Implementierungen in Unit-Tests ohne echte Credentials.
protocol AuthServiceProtocol {

    /// Gibt `true` zurück wenn das Passwort korrekt ist.
    func login(password: String) -> Bool

    /// Validiert ein Passwort und gibt bei Fehler den passenden `AuthError` zurück.
    func validatePassword(_ password: String) -> AuthError?

    /// Gibt `true` zurück wenn das Gerät biometrische Authentifizierung unterstützt.
    func canUseBiometrics() -> Bool

    /// Führt eine biometrische Authentifizierung durch.
    func authenticateWithBiometrics() async -> Bool
}

import Testing
import Foundation
@testable import BKKAtomium

/// Unit tests for the `InsuredPerson` model, verifying name concatenation, initial relationship state,
/// and insurance number storage.
@Suite("InsuredPerson Model Tests")
struct InsuredPersonTests {

    /// Verifies that `fullName` concatenates `firstName` and `lastName` with a space.
    @Test("InsuredPerson hat korrekten vollständigen Namen")
    func testFullName() {
        let person = InsuredPerson(
            lastName: "Drapatz",
            firstName: "Christian",
            birthDate: Date(),
            insuranceNumber: "A987654321",
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        #expect(person.fullName == "Christian Drapatz")
    }

    /// Verifies that a newly created `InsuredPerson` has empty relationship arrays for all contact types.
    @Test("InsuredPerson wird mit leeren Beziehungs-Arrays initialisiert")
    func testInitialEmptyRelationships() {
        let person = InsuredPerson(
            lastName: "Drapatz",
            firstName: "Christian",
            birthDate: Date(),
            insuranceNumber: "A987654321",
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        #expect(person.addresses.isEmpty)
        #expect(person.phoneNumbers.isEmpty)
        #expect(person.bankAccounts.isEmpty)
        #expect(person.emailAddresses.isEmpty)
    }

    /// Verifies that the `insuranceNumber` provided at initialisation is stored unchanged.
    @Test("Versicherungsnummer wird korrekt gespeichert")
    func testInsuranceNumber() {
        let insuranceNumber = "A987654321"
        let person = InsuredPerson(
            lastName: "Drapatz",
            firstName: "Christian",
            birthDate: Date(),
            insuranceNumber: insuranceNumber,
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        #expect(person.insuranceNumber == insuranceNumber)
    }
}

/// Unit tests for the `BankAccount` model, covering IBAN normalisation, formatted IBAN, and masked IBAN.
@Suite("BankAccount Model Tests")
struct BankAccountModelTests {

    /// Verifies that the IBAN is uppercased and whitespace-stripped, and that the BIC is uppercased.
    @Test("IBAN wird großgeschrieben und ohne Leerzeichen gespeichert")
    func testIBANNormalization() {
        let account = BankAccount(
            iban: "de89 3704 0044 0532 0130 00",
            bic: "cobadeffxxx",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz"
        )
        #expect(account.iban == "DE89370400440532013000")
        #expect(account.bic == "COBADEFFXXX")
    }

    /// Verifies that `formattedIBAN` inserts a space every four characters.
    @Test("Formatierte IBAN enthält Leerzeichen alle 4 Zeichen")
    func testFormattedIBAN() {
        let account = BankAccount(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz"
        )
        #expect(account.formattedIBAN == "DE89 3704 0044 0532 0130 00")
    }

    /// Verifies that `maskedIBAN` starts with the first four characters and ends with the last four characters.
    @Test("Maskierte IBAN zeigt nur Anfang und Ende")
    func testMaskedIBAN() {
        let account = BankAccount(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz"
        )
        let masked = account.maskedIBAN
        #expect(masked.hasPrefix("DE89"))
        #expect(masked.hasSuffix("3000"))
    }
}

/// Unit tests for the `Address` model, verifying single-line and multi-line address formatting.
@Suite("Address Model Tests")
struct AddressModelTests {

    /// Verifies that `singleLineAddress` returns a comma-separated, one-line representation.
    @Test("Einzeilige Adresse ist korrekt formatiert")
    func testSingleLineAddress() {
        let address = Address(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen"
        )
        #expect(address.singleLineAddress == "Am Mühlenbach 105, 45147 Essen")
    }

    /// Verifies that `formattedAddress` includes all address components across multiple lines.
    @Test("Mehrzeilige Adresse enthält alle Zeilen")
    func testFormattedAddress() {
        let address = Address(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen",
            country: "Deutschland"
        )
        let formatted = address.formattedAddress
        #expect(formatted.contains("Am Mühlenbach 105"))
        #expect(formatted.contains("45147 Essen"))
        #expect(formatted.contains("Deutschland"))
    }
}

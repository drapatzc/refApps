import Testing
import Foundation
@testable import BKKOrano

// MARK: - InsuredPerson

@Suite("InsuredPerson model")
struct InsuredPersonTests {

    @Test("fullName combines first and last name with a space")
    func fullNameCombinesFirstAndLast() {
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

    @Test("Relationships start empty")
    func relationshipsStartEmpty() {
        let person = InsuredPerson(
            lastName: "Test",
            firstName: "Max",
            birthDate: Date(),
            insuranceNumber: "Z",
            pensionInsuranceNumber: "Y",
            taxId: "X"
        )
        #expect(person.addresses.isEmpty)
        #expect(person.phoneNumbers.isEmpty)
        #expect(person.bankAccounts.isEmpty)
        #expect(person.emailAddresses.isEmpty)
    }
}

// MARK: - BankAccount formatting

@Suite("BankAccount masking & formatting")
struct BankAccountFormattingTests {

    @Test("Normalizes IBAN to canonical form on init")
    func normalizesIBAN() {
        let account = BankAccount(
            iban: "de89 3704 0044 0532 0130 00",
            bic: "cobadeffxxx",
            bankName: "Commerzbank AG",
            accountHolder: "Test"
        )
        #expect(account.iban == "DE89370400440532013000")
        #expect(account.bic == "COBADEFFXXX")
    }

    @Test("maskedIBAN keeps prefix and suffix visible")
    func maskingBehavior() {
        let account = BankAccount(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Test"
        )
        #expect(account.maskedIBAN.hasPrefix("DE89"))
        #expect(account.maskedIBAN.hasSuffix("3000"))
        #expect(account.maskedIBAN.contains("•"))
    }

    @Test("formattedIBAN inserts a space after every four chars")
    func formattedIBAN() {
        let account = BankAccount(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Test"
        )
        #expect(account.formattedIBAN == "DE89 3704 0044 0532 0130 00")
    }
}

// MARK: - Address formatting

@Suite("Address formatting")
struct AddressFormattingTests {

    @Test("singleLineAddress concatenates street, house, postal, city")
    func singleLine() {
        let address = Address(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen"
        )
        #expect(address.singleLineAddress == "Am Mühlenbach 105, 45147 Essen")
    }

    @Test("formattedAddress uses newlines for multi-line display")
    func multiLine() {
        let address = Address(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen"
        )
        #expect(address.formattedAddress.contains("\n"))
    }
}

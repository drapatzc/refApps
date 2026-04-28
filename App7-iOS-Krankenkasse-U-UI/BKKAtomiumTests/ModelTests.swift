import Testing
import Foundation
@testable import BKKAtomium

// MARK: - PhoneNumber Model

@Suite("PhoneNumber Model Tests")
struct PhoneNumberModelTests {

    @Test("PhoneNumber wird korrekt initialisiert")
    func testInit() {
        let phone = PhoneNumber(
            number: "+49 170 9876543",
            phoneType: PhoneType.mobile.rawValue,
            isPrimary: true
        )
        #expect(phone.number == "+49 170 9876543")
        #expect(phone.phoneType == PhoneType.mobile.rawValue)
        #expect(phone.isPrimary == true)
        #expect(phone.person == nil)
    }

    @Test("Standardmäßiger Typ ist Mobil")
    func testDefaultPhoneType() {
        let phone = PhoneNumber(number: "0201 12345")
        #expect(phone.phoneType == PhoneType.mobile.rawValue)
    }

    @Test("Standardmäßig nicht primär")
    func testDefaultNotPrimary() {
        let phone = PhoneNumber(number: "0201 12345")
        #expect(phone.isPrimary == false)
    }

    @Test("Jede Instanz hat eine einmalige UUID")
    func testUniqueIDs() {
        let p1 = PhoneNumber(number: "0201 111111")
        let p2 = PhoneNumber(number: "0201 222222")
        #expect(p1.id != p2.id)
    }
}

// MARK: - EmailAddress Model

@Suite("EmailAddress Model Tests")
struct EmailAddressModelTests {

    @Test("EmailAddress wird korrekt initialisiert")
    func testInit() {
        let email = EmailAddress(
            email: "test@example.de",
            emailType: EmailType.personal.rawValue,
            isPrimary: true
        )
        #expect(email.email == "test@example.de")
        #expect(email.emailType == EmailType.personal.rawValue)
        #expect(email.isPrimary == true)
        #expect(email.person == nil)
    }

    @Test("Standardmäßiger Typ ist Privat")
    func testDefaultEmailType() {
        let email = EmailAddress(email: "test@example.de")
        #expect(email.emailType == EmailType.personal.rawValue)
    }

    @Test("Standardmäßig nicht primär")
    func testDefaultNotPrimary() {
        let email = EmailAddress(email: "test@example.de")
        #expect(email.isPrimary == false)
    }

    @Test("Jede Instanz hat eine einmalige UUID")
    func testUniqueIDs() {
        let e1 = EmailAddress(email: "a@test.de")
        let e2 = EmailAddress(email: "b@test.de")
        #expect(e1.id != e2.id)
    }
}

// MARK: - AddressType Enum

@Suite("AddressType Enum Tests")
struct AddressTypeEnumTests {

    @Test("RawValues sind korrekt")
    func testRawValues() {
        #expect(AddressType.primary.rawValue == "Hauptwohnsitz")
        #expect(AddressType.secondary.rawValue == "Nebenwohnsitz")
        #expect(AddressType.work.rawValue == "Arbeit")
    }

    @Test("allCases enthält genau 3 Fälle")
    func testAllCasesCount() {
        #expect(AddressType.allCases.count == 3)
    }

    @Test("Init aus rawValue funktioniert")
    func testInitFromRawValue() {
        #expect(AddressType(rawValue: "Hauptwohnsitz") == .primary)
        #expect(AddressType(rawValue: "Nebenwohnsitz") == .secondary)
        #expect(AddressType(rawValue: "Arbeit") == .work)
    }

    @Test("Ungültiger rawValue ergibt nil")
    func testInvalidRawValue() {
        #expect(AddressType(rawValue: "Unbekannt") == nil)
    }
}

// MARK: - PhoneType Enum

@Suite("PhoneType Enum Tests")
struct PhoneTypeEnumTests {

    @Test("RawValues sind korrekt")
    func testRawValues() {
        #expect(PhoneType.mobile.rawValue == "Mobil")
        #expect(PhoneType.landline.rawValue == "Festnetz")
        #expect(PhoneType.work.rawValue == "Arbeit")
        #expect(PhoneType.fax.rawValue == "Fax")
    }

    @Test("allCases enthält genau 4 Fälle")
    func testAllCasesCount() {
        #expect(PhoneType.allCases.count == 4)
    }

    @Test("Icons sind korrekte SF Symbols Namen")
    func testIcons() {
        #expect(PhoneType.mobile.icon == "iphone")
        #expect(PhoneType.landline.icon == "phone.fill")
        #expect(PhoneType.work.icon == "building.2.fill")
        #expect(PhoneType.fax.icon == "printer.fill")
    }

    @Test("Init aus rawValue funktioniert")
    func testInitFromRawValue() {
        #expect(PhoneType(rawValue: "Mobil") == .mobile)
        #expect(PhoneType(rawValue: "Fax") == .fax)
        #expect(PhoneType(rawValue: "Unbekannt") == nil)
    }
}

// MARK: - EmailType Enum

@Suite("EmailType Enum Tests")
struct EmailTypeEnumTests {

    @Test("RawValues sind korrekt")
    func testRawValues() {
        #expect(EmailType.personal.rawValue == "Privat")
        #expect(EmailType.work.rawValue == "Arbeit")
        #expect(EmailType.other.rawValue == "Sonstige")
    }

    @Test("allCases enthält genau 3 Fälle")
    func testAllCasesCount() {
        #expect(EmailType.allCases.count == 3)
    }

    @Test("Icons sind korrekte SF Symbols Namen")
    func testIcons() {
        #expect(EmailType.personal.icon == "envelope.fill")
        #expect(EmailType.work.icon == "building.2.fill")
        #expect(EmailType.other.icon == "envelope.badge.fill")
    }

    @Test("Init aus rawValue funktioniert")
    func testInitFromRawValue() {
        #expect(EmailType(rawValue: "Privat") == .personal)
        #expect(EmailType(rawValue: "Arbeit") == .work)
        #expect(EmailType(rawValue: "Sonstige") == .other)
        #expect(EmailType(rawValue: "Unbekannt") == nil)
    }
}

// MARK: - BankAccount Model (erweitert)

@Suite("BankAccount Model Erweiterte Tests")
struct BankAccountModelExtendedTests {

    @Test("maskedIBAN bei IBAN mit ≤ 6 Zeichen bleibt unverändert")
    func testShortIBANMasking() {
        let account = BankAccount(
            iban: "ABCDE", bic: "TESTBIC",
            bankName: "Test", accountHolder: "Test"
        )
        #expect(account.maskedIBAN == account.iban)
    }

    @Test("maskedIBAN hat mittlere Bullet-Zeichen")
    func testMaskedIBANBullets() {
        let account = BankAccount(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Test"
        )
        #expect(account.maskedIBAN.contains("•"))
    }

    @Test("Standardmäßig nicht primär")
    func testDefaultNotPrimary() {
        let account = BankAccount(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Bank", accountHolder: "User"
        )
        #expect(account.isPrimary == false)
    }

    @Test("Jede Instanz hat eine einmalige UUID")
    func testUniqueIDs() {
        let a1 = BankAccount(iban: "DE89370400440532013000", bic: "COBADEFFXXX", bankName: "B1", accountHolder: "U")
        let a2 = BankAccount(iban: "DE89370400440532013000", bic: "COBADEFFXXX", bankName: "B2", accountHolder: "U")
        #expect(a1.id != a2.id)
    }

    @Test("formattedIBAN hat Leerzeichen nach jeweils 4 Zeichen")
    func testFormattedIBANGrouping() {
        let account = BankAccount(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Bank", accountHolder: "User"
        )
        let parts = account.formattedIBAN.split(separator: " ")
        #expect(parts.allSatisfy { $0.count == 4 || $0.count <= 4 })
    }
}

// MARK: - Address Model (erweitert)

@Suite("Address Model Erweiterte Tests")
struct AddressModelExtendedTests {

    @Test("Standard-Land ist Deutschland")
    func testDefaultCountry() {
        let address = Address(
            street: "Teststr.", houseNumber: "1",
            postalCode: "12345", city: "Berlin"
        )
        #expect(address.country == "Deutschland")
    }

    @Test("Standardmäßig nicht primär")
    func testDefaultNotPrimary() {
        let address = Address(
            street: "Teststr.", houseNumber: "1",
            postalCode: "12345", city: "Berlin"
        )
        #expect(address.isPrimary == false)
    }

    @Test("formattedAddress enthält Zeilenumbrüche")
    func testFormattedAddressHasNewlines() {
        let address = Address(
            street: "Teststr.", houseNumber: "1",
            postalCode: "12345", city: "Berlin"
        )
        #expect(address.formattedAddress.contains("\n"))
    }

    @Test("Jede Instanz hat eine einmalige UUID")
    func testUniqueIDs() {
        let a1 = Address(street: "Str. A", houseNumber: "1", postalCode: "12345", city: "Berlin")
        let a2 = Address(street: "Str. B", houseNumber: "2", postalCode: "12345", city: "Berlin")
        #expect(a1.id != a2.id)
    }

    @Test("Standard-Adresstyp ist Hauptwohnsitz")
    func testDefaultAddressType() {
        let address = Address(
            street: "Teststr.", houseNumber: "1",
            postalCode: "12345", city: "Berlin"
        )
        #expect(address.addressType == AddressType.primary.rawValue)
    }
}

// MARK: - InsuredPerson Model (erweitert)

@Suite("InsuredPerson Model Erweiterte Tests")
struct InsuredPersonModelExtendedTests {

    @Test("Jede Instanz hat eine einmalige UUID")
    func testUniqueIDs() {
        let p1 = InsuredPerson(
            lastName: "A", firstName: "B", birthDate: Date(),
            insuranceNumber: "X", pensionInsuranceNumber: "Y", taxId: "Z"
        )
        let p2 = InsuredPerson(
            lastName: "C", firstName: "D", birthDate: Date(),
            insuranceNumber: "X", pensionInsuranceNumber: "Y", taxId: "Z"
        )
        #expect(p1.id != p2.id)
    }

    @Test("Geburtsdatum wird korrekt gespeichert")
    func testBirthDateStorage() {
        let calendar = Calendar.current
        let birthDate = calendar.date(from: DateComponents(year: 1990, month: 6, day: 15))!
        let person = InsuredPerson(
            lastName: "Test", firstName: "User", birthDate: birthDate,
            insuranceNumber: "A123", pensionInsuranceNumber: "B456", taxId: "C789"
        )
        let components = calendar.dateComponents([.year, .month, .day], from: person.birthDate)
        #expect(components.year == 1990)
        #expect(components.month == 6)
        #expect(components.day == 15)
    }

    @Test("taxId und pensionInsuranceNumber werden korrekt gespeichert")
    func testPersonalNumbers() {
        let person = InsuredPerson(
            lastName: "Test", firstName: "User", birthDate: Date(),
            insuranceNumber: "A987654321",
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        #expect(person.taxId == "49823756102")
        #expect(person.pensionInsuranceNumber == "65 220385 D 001")
    }
}

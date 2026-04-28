import Testing
import SwiftData
import Foundation
@testable import BKKAtomium

// MARK: - Hilfsfunktionen

private func makeInMemoryContainer() throws -> ModelContainer {
    let schema = Schema([
        InsuredPerson.self, Address.self, PhoneNumber.self,
        BankAccount.self, EmailAddress.self,
        Invoice.self, InsuranceDocument.self, BenefitRequest.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}

private func makeTestPerson() -> InsuredPerson {
    InsuredPerson(
        lastName: "Testmann",
        firstName: "Max",
        birthDate: Date(),
        insuranceNumber: "T123456789",
        pensionInsuranceNumber: "12 345678 T 001",
        taxId: "12345678901"
    )
}

// MARK: - AddressRepository Tests

@Suite("AddressRepository Tests")
@MainActor
struct AddressRepositoryTests {

    @Test("add() fügt gültige Adresse hinzu")
    func testAddValidAddress() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Teststraße", houseNumber: "42",
            postalCode: "45147", city: "Essen",
            country: "Deutschland",
            addressType: AddressType.primary.rawValue,
            isPrimary: true, to: person
        )

        #expect(person.addresses.count == 1)
        #expect(person.addresses.first?.city == "Essen")
        #expect(person.addresses.first?.isPrimary == true)
    }

    @Test("add() wirft Fehler bei leerer Straße")
    func testAddEmptyStreetThrows() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        #expect(throws: (any Error).self) {
            try repo.add(
                street: "", houseNumber: "42", postalCode: "45147",
                city: "Essen", country: "Deutschland",
                addressType: AddressType.primary.rawValue,
                isPrimary: false, to: person
            )
        }
        #expect(person.addresses.isEmpty)
    }

    @Test("add() mit isPrimary demoted vorherige primäre Adressen")
    func testAddPrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Erste Str.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: true, to: person
        )
        try repo.add(
            street: "Zweite Str.", houseNumber: "2", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: true, to: person
        )

        let primaryCount = person.addresses.filter(\.isPrimary).count
        #expect(primaryCount == 1)
        #expect(person.addresses.filter(\.isPrimary).first?.street == "Zweite Str.")
    }

    @Test("add() trimmt Whitespace aus Feldern")
    func testAddWhitespaceTrimming() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "  Teststraße  ", houseNumber: "  1  ",
            postalCode: "45147", city: "  Essen  ",
            country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: false, to: person
        )

        let address = person.addresses.first!
        #expect(address.street == "Teststraße")
        #expect(address.houseNumber == "1")
        #expect(address.city == "Essen")
    }

    @Test("fetchAll() sortiert primary zuerst, dann alphabetisch nach Stadt")
    func testFetchAllSorting() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Weg", houseNumber: "1", postalCode: "45147",
            city: "Dortmund", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: false, to: person
        )
        try repo.add(
            street: "Allee", houseNumber: "2", postalCode: "45147",
            city: "Bochum", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: true, to: person
        )

        let sorted = repo.fetchAll(for: person)
        #expect(sorted.first?.isPrimary == true)
    }

    @Test("update() aktualisiert alle Felder")
    func testUpdateAddress() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Alte Str.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: false, to: person
        )

        let address = person.addresses.first!
        try repo.update(
            address,
            street: "Neue Str.", houseNumber: "99", postalCode: "10115",
            city: "Berlin", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: false, person: person
        )

        #expect(address.street == "Neue Str.")
        #expect(address.city == "Berlin")
        #expect(address.houseNumber == "99")
        #expect(address.postalCode == "10115")
    }

    @Test("update() wirft Fehler bei ungültigen Feldern")
    func testUpdateInvalidThrows() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Teststr.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: false, to: person
        )

        let address = person.addresses.first!
        #expect(throws: (any Error).self) {
            try repo.update(
                address, street: "", houseNumber: "1", postalCode: "45147",
                city: "Essen", country: "Deutschland",
                addressType: AddressType.primary.rawValue, isPrimary: false, person: person
            )
        }
    }

    @Test("delete() entfernt die Adresse")
    func testDeleteAddress() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Teststr.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: true, to: person
        )

        let address = person.addresses.first!
        try repo.delete(address)
        #expect(person.addresses.isEmpty)
    }

    @Test("update() mit isPrimary demoted andere Adressen")
    func testUpdatePrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = AddressRepository(context: context)
        try repo.add(
            street: "Erste Str.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: true, to: person
        )
        try repo.add(
            street: "Zweite Str.", houseNumber: "2", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: false, to: person
        )

        let secondAddress = person.addresses.first { !$0.isPrimary }!
        try repo.update(
            secondAddress, street: "Zweite Str.", houseNumber: "2", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: true, person: person
        )

        #expect(person.addresses.filter(\.isPrimary).count == 1)
        #expect(person.addresses.filter(\.isPrimary).first?.id == secondAddress.id)
    }
}

// MARK: - PhoneRepository Tests

@Suite("PhoneRepository Tests")
@MainActor
struct PhoneRepositoryTests {

    @Test("add() fügt gültige Telefonnummer hinzu")
    func testAddValidPhone() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(
            number: "+49 170 9876543",
            phoneType: PhoneType.mobile.rawValue,
            isPrimary: true, to: person
        )

        #expect(person.phoneNumbers.count == 1)
        #expect(person.phoneNumbers.first?.isPrimary == true)
    }

    @Test("add() wirft Fehler bei ungültiger Nummer")
    func testAddInvalidPhoneThrows() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        #expect(throws: (any Error).self) {
            try repo.add(number: "abc", phoneType: PhoneType.mobile.rawValue, isPrimary: false, to: person)
        }
        #expect(person.phoneNumbers.isEmpty)
    }

    @Test("add() mit isPrimary demoted vorherige primäre Nummern")
    func testAddPrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(number: "0201 123456", phoneType: PhoneType.landline.rawValue, isPrimary: true, to: person)
        try repo.add(number: "+49 170 9876543", phoneType: PhoneType.mobile.rawValue, isPrimary: true, to: person)

        #expect(person.phoneNumbers.filter(\.isPrimary).count == 1)
        #expect(person.phoneNumbers.filter(\.isPrimary).first?.number == "+49 170 9876543")
    }

    @Test("fetchAll() sortiert primary zuerst")
    func testFetchAllSortsPrimaryFirst() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(number: "0201 654321", phoneType: PhoneType.landline.rawValue, isPrimary: false, to: person)
        try repo.add(number: "+49 170 123456", phoneType: PhoneType.mobile.rawValue, isPrimary: true, to: person)

        #expect(repo.fetchAll(for: person).first?.isPrimary == true)
    }

    @Test("update() aktualisiert Telefonnummer")
    func testUpdatePhone() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(number: "0201 123456", phoneType: PhoneType.landline.rawValue, isPrimary: false, to: person)

        let phone = person.phoneNumbers.first!
        try repo.update(phone, number: "+49 201 654321", phoneType: PhoneType.work.rawValue, isPrimary: true, person: person)

        #expect(phone.number == "+49 201 654321")
        #expect(phone.phoneType == PhoneType.work.rawValue)
        #expect(phone.isPrimary == true)
    }

    @Test("delete() entfernt die Telefonnummer")
    func testDeletePhone() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(number: "0201 123456", phoneType: PhoneType.mobile.rawValue, isPrimary: true, to: person)

        let phone = person.phoneNumbers.first!
        try repo.delete(phone)
        #expect(person.phoneNumbers.isEmpty)
    }

    @Test("update() demoted andere Nummern wenn isPrimary")
    func testUpdatePrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(number: "0201 111111", phoneType: PhoneType.landline.rawValue, isPrimary: true, to: person)
        try repo.add(number: "0201 222222", phoneType: PhoneType.landline.rawValue, isPrimary: false, to: person)

        let second = person.phoneNumbers.first { !$0.isPrimary }!
        try repo.update(second, number: "0201 222222", phoneType: PhoneType.landline.rawValue, isPrimary: true, person: person)

        #expect(person.phoneNumbers.filter(\.isPrimary).count == 1)
    }

    @Test("add() trimmt Whitespace aus Nummer")
    func testAddWhitespaceTrimming() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = PhoneRepository(context: context)
        try repo.add(number: "  0201 123456  ", phoneType: PhoneType.landline.rawValue, isPrimary: false, to: person)

        #expect(person.phoneNumbers.first?.number == "0201 123456")
    }
}

// MARK: - BankAccountRepository Tests

@Suite("BankAccountRepository Tests")
@MainActor
struct BankAccountRepositoryTests {

    @Test("add() fügt gültiges Bankkonto hinzu")
    func testAddValidBankAccount() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank AG", accountHolder: "Max Testmann",
            isPrimary: true, to: person
        )

        #expect(person.bankAccounts.count == 1)
        #expect(person.bankAccounts.first?.bankName == "Commerzbank AG")
        #expect(person.bankAccounts.first?.isPrimary == true)
    }

    @Test("add() normalisiert IBAN zu Großbuchstaben ohne Leerzeichen")
    func testAddNormalizesIBAN() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "de89 3704 0044 0532 0130 00", bic: "cobadeffxxx",
            bankName: "Commerzbank", accountHolder: "Max Testmann",
            isPrimary: false, to: person
        )

        #expect(person.bankAccounts.first?.iban == "DE89370400440532013000")
        #expect(person.bankAccounts.first?.bic == "COBADEFFXXX")
    }

    @Test("add() wirft Fehler bei ungültiger IBAN")
    func testAddInvalidIBANThrows() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        #expect(throws: (any Error).self) {
            try repo.add(
                iban: "INVALID", bic: "COBADEFFXXX",
                bankName: "Test Bank", accountHolder: "Test User",
                isPrimary: false, to: person
            )
        }
        #expect(person.bankAccounts.isEmpty)
    }

    @Test("add() mit isPrimary demoted vorherige Konten")
    func testAddPrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Max",
            isPrimary: true, to: person
        )
        try repo.add(
            iban: "DE44500105175407324931", bic: "BELADEBE",
            bankName: "Berliner Sparkasse", accountHolder: "Max",
            isPrimary: true, to: person
        )

        #expect(person.bankAccounts.filter(\.isPrimary).count == 1)
        #expect(person.bankAccounts.filter(\.isPrimary).first?.bankName == "Berliner Sparkasse")
    }

    @Test("update() aktualisiert alle Felder")
    func testUpdateBankAccount() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Alte Bank", accountHolder: "Max",
            isPrimary: false, to: person
        )

        let account = person.bankAccounts.first!
        try repo.update(
            account,
            iban: "DE44500105175407324931", bic: "BELADEBE",
            bankName: "Neue Bank", accountHolder: "Max",
            isPrimary: true, person: person
        )

        #expect(account.bankName == "Neue Bank")
        #expect(account.iban == "DE44500105175407324931")
        #expect(account.isPrimary == true)
    }

    @Test("update() normalisiert IBAN und BIC")
    func testUpdateNormalization() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Bank", accountHolder: "User",
            isPrimary: false, to: person
        )

        let account = person.bankAccounts.first!
        try repo.update(
            account,
            iban: "de44 5001 0517 5407 3249 31", bic: "beladebe",
            bankName: "Bank", accountHolder: "User",
            isPrimary: false, person: person
        )

        #expect(account.iban == "DE44500105175407324931")
        #expect(account.bic == "BELADEBE")
    }

    @Test("delete() entfernt das Bankkonto")
    func testDeleteBankAccount() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Max",
            isPrimary: true, to: person
        )

        let account = person.bankAccounts.first!
        try repo.delete(account)
        #expect(person.bankAccounts.isEmpty)
    }

    @Test("fetchAll() sortiert primary zuerst dann nach Bankname")
    func testFetchAllSorting() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = BankAccountRepository(context: context)
        try repo.add(
            iban: "DE44500105175407324931", bic: "BELADEBE",
            bankName: "Berliner Sparkasse", accountHolder: "Max",
            isPrimary: false, to: person
        )
        try repo.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Max",
            isPrimary: true, to: person
        )

        let sorted = repo.fetchAll(for: person)
        #expect(sorted.first?.isPrimary == true)
    }
}

// MARK: - EmailRepository Tests

@Suite("EmailRepository Tests")
@MainActor
struct EmailRepositoryTests {

    @Test("add() fügt gültige E-Mail hinzu und speichert in Kleinbuchstaben")
    func testAddValidEmailLowercased() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(
            email: "TEST@EXAMPLE.DE",
            emailType: EmailType.personal.rawValue,
            isPrimary: true, to: person
        )

        #expect(person.emailAddresses.count == 1)
        #expect(person.emailAddresses.first?.email == "test@example.de")
        #expect(person.emailAddresses.first?.isPrimary == true)
    }

    @Test("add() wirft Fehler bei ungültiger E-Mail")
    func testAddInvalidEmailThrows() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        #expect(throws: (any Error).self) {
            try repo.add(email: "ungültige-email", emailType: EmailType.personal.rawValue, isPrimary: false, to: person)
        }
        #expect(person.emailAddresses.isEmpty)
    }

    @Test("add() mit isPrimary demoted vorherige E-Mail-Adressen")
    func testAddPrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(email: "first@test.de", emailType: EmailType.personal.rawValue, isPrimary: true, to: person)
        try repo.add(email: "second@test.de", emailType: EmailType.work.rawValue, isPrimary: true, to: person)

        #expect(person.emailAddresses.filter(\.isPrimary).count == 1)
        #expect(person.emailAddresses.filter(\.isPrimary).first?.email == "second@test.de")
    }

    @Test("update() aktualisiert E-Mail und normalisiert zu Kleinbuchstaben")
    func testUpdateEmailLowercased() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(email: "old@test.de", emailType: EmailType.personal.rawValue, isPrimary: false, to: person)

        let emailAddr = person.emailAddresses.first!
        try repo.update(
            emailAddr, email: "NEW@TEST.DE",
            emailType: EmailType.work.rawValue, isPrimary: true, person: person
        )

        #expect(emailAddr.email == "new@test.de")
        #expect(emailAddr.emailType == EmailType.work.rawValue)
        #expect(emailAddr.isPrimary == true)
    }

    @Test("update() demoted andere Adressen wenn isPrimary")
    func testUpdatePrimaryDemotion() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(email: "first@test.de", emailType: EmailType.personal.rawValue, isPrimary: true, to: person)
        try repo.add(email: "second@test.de", emailType: EmailType.work.rawValue, isPrimary: false, to: person)

        let second = person.emailAddresses.first { !$0.isPrimary }!
        try repo.update(second, email: "second@test.de", emailType: EmailType.work.rawValue, isPrimary: true, person: person)

        #expect(person.emailAddresses.filter(\.isPrimary).count == 1)
    }

    @Test("delete() entfernt die E-Mail-Adresse")
    func testDeleteEmail() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(email: "test@test.de", emailType: EmailType.personal.rawValue, isPrimary: true, to: person)

        let emailAddr = person.emailAddresses.first!
        try repo.delete(emailAddr)
        #expect(person.emailAddresses.isEmpty)
    }

    @Test("fetchAll() sortiert primary zuerst dann alphabetisch")
    func testFetchAllSortsPrimaryFirst() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(email: "z@test.de", emailType: EmailType.work.rawValue, isPrimary: false, to: person)
        try repo.add(email: "a@test.de", emailType: EmailType.personal.rawValue, isPrimary: true, to: person)

        #expect(repo.fetchAll(for: person).first?.isPrimary == true)
    }

    @Test("add() trimmt Whitespace aus E-Mail")
    func testAddWhitespaceTrimming() throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext
        let person = makeTestPerson()
        context.insert(person)

        let repo = EmailRepository(context: context)
        try repo.add(email: "  test@test.de  ", emailType: EmailType.personal.rawValue, isPrimary: false, to: person)

        #expect(person.emailAddresses.first?.email == "test@test.de")
    }
}

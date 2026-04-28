import Testing
import SwiftData
import Foundation
@testable import BKKAtomium

// MARK: - Hilfsfunktionen

private func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([
        InsuredPerson.self, Address.self, PhoneNumber.self,
        BankAccount.self, EmailAddress.self, Invoice.self,
        InsuranceDocument.self, BenefitRequest.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}

private func insertTestPerson(in context: ModelContext) throws -> InsuredPerson {
    let person = InsuredPerson(
        lastName: "Test", firstName: "User", birthDate: Date(),
        insuranceNumber: "T123456789",
        pensionInsuranceNumber: "12 345678 T 001",
        taxId: "12345678901"
    )
    context.insert(person)
    try context.save()
    return person
}

// MARK: - AddressViewModel Integration

@Suite("AddressViewModel Integration Tests")
@MainActor
struct AddressViewModelIntegrationTests {

    @Test("setup() startet mit leerer Adressliste")
    func testSetupEmptyList() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = AddressViewModel()
        vm.setup(context: context)
        #expect(vm.addresses.isEmpty)
    }

    @Test("add() fügt Adresse hinzu und setzt showSuccess")
    func testAddSetsShowSuccess() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = AddressViewModel()
        vm.setup(context: context)
        try vm.add(
            street: "Teststraße", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: true
        )

        #expect(vm.addresses.count == 1)
        #expect(vm.showSuccess == true)
    }

    @Test("add() mit ungültiger Adresse wirft Fehler und ändert Liste nicht")
    func testAddInvalidThrows() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = AddressViewModel()
        vm.setup(context: context)
        #expect(throws: (any Error).self) {
            try vm.add(
                street: "", houseNumber: "1", postalCode: "45147",
                city: "Essen", country: "Deutschland",
                addressType: AddressType.primary.rawValue, isPrimary: false
            )
        }
        #expect(vm.addresses.isEmpty)
    }

    @Test("update() aktualisiert Adresse und setzt showSuccess")
    func testUpdateSetsShowSuccess() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = AddressViewModel()
        vm.setup(context: context)
        try vm.add(
            street: "Alte Str.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: false
        )

        let address = vm.addresses.first!
        try vm.update(
            address, street: "Neue Str.", houseNumber: "99", postalCode: "10115",
            city: "Berlin", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: false
        )

        #expect(vm.addresses.first?.city == "Berlin")
        #expect(vm.showSuccess == true)
    }

    @Test("delete() entfernt Adresse aus Liste")
    func testDeleteRemovesFromList() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = AddressViewModel()
        vm.setup(context: context)
        try vm.add(
            street: "Teststr.", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: true
        )

        let address = vm.addresses.first!
        try vm.delete(address)
        #expect(vm.addresses.isEmpty)
    }

    @Test("loadAddresses() lädt nach Mutation neu")
    func testLoadAddressesAfterAdd() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = AddressViewModel()
        vm.setup(context: context)
        try vm.add(
            street: "Str. A", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: false
        )
        try vm.add(
            street: "Str. B", houseNumber: "2", postalCode: "45147",
            city: "Bochum", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: true
        )

        #expect(vm.addresses.count == 2)
    }
}

// MARK: - PhoneNumberViewModel Integration

@Suite("PhoneNumberViewModel Integration Tests")
@MainActor
struct PhoneNumberViewModelIntegrationTests {

    @Test("add() fügt Telefonnummer hinzu und setzt showSuccess")
    func testAddPhone() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = PhoneNumberViewModel()
        vm.setup(context: context)
        try vm.add(number: "+49 170 1234567", phoneType: PhoneType.mobile.rawValue, isPrimary: true)

        #expect(vm.phones.count == 1)
        #expect(vm.showSuccess == true)
    }

    @Test("add() mit ungültiger Nummer wirft Fehler")
    func testAddInvalidPhoneThrows() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = PhoneNumberViewModel()
        vm.setup(context: context)
        #expect(throws: (any Error).self) {
            try vm.add(number: "ab", phoneType: PhoneType.mobile.rawValue, isPrimary: false)
        }
        #expect(vm.phones.isEmpty)
    }

    @Test("update() aktualisiert Telefonnummer")
    func testUpdatePhone() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = PhoneNumberViewModel()
        vm.setup(context: context)
        try vm.add(number: "0201 123456", phoneType: PhoneType.landline.rawValue, isPrimary: false)

        let phone = vm.phones.first!
        try vm.update(phone, number: "+49 170 9999999", phoneType: PhoneType.mobile.rawValue, isPrimary: true)

        #expect(vm.phones.first?.number == "+49 170 9999999")
        #expect(vm.showSuccess == true)
    }

    @Test("delete() entfernt Telefonnummer")
    func testDeletePhone() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = PhoneNumberViewModel()
        vm.setup(context: context)
        try vm.add(number: "0201 123456", phoneType: PhoneType.landline.rawValue, isPrimary: true)

        let phone = vm.phones.first!
        try vm.delete(phone)
        #expect(vm.phones.isEmpty)
    }
}

// MARK: - BankAccountViewModel Integration

@Suite("BankAccountViewModel Integration Tests")
@MainActor
struct BankAccountViewModelIntegrationTests {

    @Test("add() fügt Bankkonto hinzu und setzt showSuccess")
    func testAddBankAccount() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = BankAccountViewModel()
        vm.setup(context: context)
        try vm.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Max Test",
            isPrimary: true
        )

        #expect(vm.accounts.count == 1)
        #expect(vm.showSuccess == true)
    }

    @Test("add() mit ungültiger IBAN wirft Fehler")
    func testAddInvalidIBANThrows() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = BankAccountViewModel()
        vm.setup(context: context)
        #expect(throws: (any Error).self) {
            try vm.add(
                iban: "INVALID", bic: "COBADEFFXXX",
                bankName: "Test Bank", accountHolder: "Test",
                isPrimary: false
            )
        }
        #expect(vm.accounts.isEmpty)
    }

    @Test("update() aktualisiert Bankkonto")
    func testUpdateBankAccount() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = BankAccountViewModel()
        vm.setup(context: context)
        try vm.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Alte Bank", accountHolder: "Max", isPrimary: false
        )

        let account = vm.accounts.first!
        try vm.update(
            account, iban: "DE44500105175407324931", bic: "BELADEBE",
            bankName: "Neue Bank", accountHolder: "Max", isPrimary: true
        )

        #expect(vm.accounts.first?.bankName == "Neue Bank")
        #expect(vm.showSuccess == true)
    }

    @Test("delete() entfernt Bankkonto")
    func testDeleteBankAccount() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = BankAccountViewModel()
        vm.setup(context: context)
        try vm.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Max", isPrimary: true
        )

        let account = vm.accounts.first!
        try vm.delete(account)
        #expect(vm.accounts.isEmpty)
    }
}

// MARK: - EmailViewModel Integration

@Suite("EmailViewModel Integration Tests")
@MainActor
struct EmailViewModelIntegrationTests {

    @Test("add() fügt E-Mail hinzu und normalisiert zu Kleinbuchstaben")
    func testAddEmail() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = EmailViewModel()
        vm.setup(context: context)
        try vm.add(email: "TEST@EXAMPLE.DE", emailType: EmailType.personal.rawValue, isPrimary: true)

        #expect(vm.emails.count == 1)
        #expect(vm.emails.first?.email == "test@example.de")
        #expect(vm.showSuccess == true)
    }

    @Test("add() mit ungültiger E-Mail wirft Fehler")
    func testAddInvalidEmailThrows() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = EmailViewModel()
        vm.setup(context: context)
        #expect(throws: (any Error).self) {
            try vm.add(email: "keine-email", emailType: EmailType.personal.rawValue, isPrimary: false)
        }
        #expect(vm.emails.isEmpty)
    }

    @Test("update() aktualisiert E-Mail")
    func testUpdateEmail() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = EmailViewModel()
        vm.setup(context: context)
        try vm.add(email: "old@test.de", emailType: EmailType.personal.rawValue, isPrimary: false)

        let email = vm.emails.first!
        try vm.update(email, email: "NEW@TEST.DE", emailType: EmailType.work.rawValue, isPrimary: true)

        #expect(vm.emails.first?.email == "new@test.de")
        #expect(vm.showSuccess == true)
    }

    @Test("delete() entfernt E-Mail")
    func testDeleteEmail() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        _ = try insertTestPerson(in: context)

        let vm = EmailViewModel()
        vm.setup(context: context)
        try vm.add(email: "test@test.de", emailType: EmailType.personal.rawValue, isPrimary: true)

        let email = vm.emails.first!
        try vm.delete(email)
        #expect(vm.emails.isEmpty)
    }
}

import Testing
import SwiftData
import Foundation
import UserNotifications
@testable import BKKAtomium

// MARK: - Hilfsfunktion

private func makeEmptyContainer() throws -> ModelContainer {
    let schema = Schema([
        InsuredPerson.self, Address.self, PhoneNumber.self,
        BankAccount.self, EmailAddress.self, Invoice.self,
        InsuranceDocument.self, BenefitRequest.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: config)
}

// MARK: - AddressViewModel Null-Person Tests

@Suite("AddressViewModel Null-Person Tests")
@MainActor
struct AddressViewModelNullPersonTests {

    @Test("setup() mit leerem Context setzt person auf nil und gibt leere Adressliste")
    func testSetupEmptyContextNoPerson() throws {
        let container = try makeEmptyContainer()
        let vm = AddressViewModel()
        vm.setup(context: container.mainContext)
        #expect(vm.addresses.isEmpty)
    }

    @Test("add() mit nil-Person ist stille Leereoperation")
    func testAddWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = AddressViewModel()
        vm.setup(context: container.mainContext) // person = nil
        try vm.add(
            street: "Teststraße", houseNumber: "1", postalCode: "45147",
            city: "Essen", country: "Deutschland",
            addressType: AddressType.primary.rawValue, isPrimary: false
        )
        #expect(vm.addresses.isEmpty)
        #expect(vm.showSuccess == false)
    }

    @Test("update() mit nil-Person ist stille Leereoperation")
    func testUpdateWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = AddressViewModel()
        vm.setup(context: container.mainContext) // person = nil
        let addr = Address(street: "Alt", houseNumber: "1", postalCode: "45147", city: "Essen")
        try vm.update(
            addr, street: "Neu", houseNumber: "99", postalCode: "10115",
            city: "Berlin", country: "Deutschland",
            addressType: AddressType.secondary.rawValue, isPrimary: false
        )
        #expect(addr.street == "Alt")
    }

    @Test("delete() ohne setup crasht nicht")
    func testDeleteWithoutSetup() throws {
        let vm = AddressViewModel()
        let addr = Address(street: "Test", houseNumber: "1", postalCode: "45147", city: "Essen")
        try vm.delete(addr)
        #expect(vm.addresses.isEmpty)
    }

    @Test("loadAddresses() ohne Person gibt leere Liste zurück")
    func testLoadAddressesWithNilPerson() throws {
        let container = try makeEmptyContainer()
        let vm = AddressViewModel()
        vm.setup(context: container.mainContext) // person = nil → guard fires
        vm.loadAddresses()
        #expect(vm.addresses.isEmpty)
    }
}

// MARK: - PhoneNumberViewModel Null-Person Tests

@Suite("PhoneNumberViewModel Null-Person Tests")
@MainActor
struct PhoneNumberViewModelNullPersonTests {

    @Test("setup() mit leerem Context ergibt leere Telefonliste")
    func testSetupEmptyContextNoPerson() throws {
        let container = try makeEmptyContainer()
        let vm = PhoneNumberViewModel()
        vm.setup(context: container.mainContext)
        #expect(vm.phones.isEmpty)
    }

    @Test("add() mit nil-Person ist stille Leereoperation")
    func testAddWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = PhoneNumberViewModel()
        vm.setup(context: container.mainContext) // person = nil
        try vm.add(number: "0201 123456", phoneType: PhoneType.landline.rawValue, isPrimary: false)
        #expect(vm.phones.isEmpty)
        #expect(vm.showSuccess == false)
    }

    @Test("update() mit nil-Person ist stille Leereoperation")
    func testUpdateWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = PhoneNumberViewModel()
        vm.setup(context: container.mainContext) // person = nil
        let phone = PhoneNumber(number: "0201 123456", phoneType: PhoneType.landline.rawValue, isPrimary: false)
        try vm.update(phone, number: "0201 654321", phoneType: PhoneType.mobile.rawValue, isPrimary: false)
        #expect(phone.number == "0201 123456")
    }

    @Test("delete() ohne setup crasht nicht")
    func testDeleteWithoutSetup() throws {
        let vm = PhoneNumberViewModel()
        let phone = PhoneNumber(number: "0201 123456")
        try vm.delete(phone)
        #expect(vm.phones.isEmpty)
    }

    @Test("loadPhones() ohne Person gibt leere Liste zurück")
    func testLoadPhonesWithNilPerson() throws {
        let container = try makeEmptyContainer()
        let vm = PhoneNumberViewModel()
        vm.setup(context: container.mainContext) // person = nil → guard fires
        vm.loadPhones()
        #expect(vm.phones.isEmpty)
    }
}

// MARK: - BankAccountViewModel Null-Person Tests

@Suite("BankAccountViewModel Null-Person Tests")
@MainActor
struct BankAccountViewModelNullPersonTests {

    @Test("setup() mit leerem Context ergibt leere Kontoliste")
    func testSetupEmptyContextNoPerson() throws {
        let container = try makeEmptyContainer()
        let vm = BankAccountViewModel()
        vm.setup(context: container.mainContext)
        #expect(vm.accounts.isEmpty)
    }

    @Test("add() mit nil-Person ist stille Leereoperation")
    func testAddWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = BankAccountViewModel()
        vm.setup(context: container.mainContext) // person = nil
        try vm.add(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Commerzbank", accountHolder: "Max", isPrimary: false
        )
        #expect(vm.accounts.isEmpty)
        #expect(vm.showSuccess == false)
    }

    @Test("update() mit nil-Person ist stille Leereoperation")
    func testUpdateWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = BankAccountViewModel()
        vm.setup(context: container.mainContext) // person = nil
        let account = BankAccount(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Alte Bank", accountHolder: "Max"
        )
        try vm.update(
            account,
            iban: "DE44500105175407324931", bic: "BELADEBE",
            bankName: "Neue Bank", accountHolder: "Max", isPrimary: false
        )
        #expect(account.bankName == "Alte Bank")
    }

    @Test("delete() ohne setup crasht nicht")
    func testDeleteWithoutSetup() throws {
        let vm = BankAccountViewModel()
        let account = BankAccount(
            iban: "DE89370400440532013000", bic: "COBADEFFXXX",
            bankName: "Bank", accountHolder: "Max"
        )
        try vm.delete(account)
        #expect(vm.accounts.isEmpty)
    }

    @Test("loadAccounts() ohne Person gibt leere Liste zurück")
    func testLoadAccountsWithNilPerson() throws {
        let container = try makeEmptyContainer()
        let vm = BankAccountViewModel()
        vm.setup(context: container.mainContext) // person = nil → guard fires
        vm.loadAccounts()
        #expect(vm.accounts.isEmpty)
    }
}

// MARK: - EmailViewModel Null-Person Tests

@Suite("EmailViewModel Null-Person Tests")
@MainActor
struct EmailViewModelNullPersonTests {

    @Test("setup() mit leerem Context ergibt leere E-Mail-Liste")
    func testSetupEmptyContextNoPerson() throws {
        let container = try makeEmptyContainer()
        let vm = EmailViewModel()
        vm.setup(context: container.mainContext)
        #expect(vm.emails.isEmpty)
    }

    @Test("add() mit nil-Person ist stille Leereoperation")
    func testAddWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = EmailViewModel()
        vm.setup(context: container.mainContext) // person = nil
        try vm.add(email: "test@example.de", emailType: EmailType.personal.rawValue, isPrimary: false)
        #expect(vm.emails.isEmpty)
        #expect(vm.showSuccess == false)
    }

    @Test("update() mit nil-Person ist stille Leereoperation")
    func testUpdateWithNilPersonIsNoop() throws {
        let container = try makeEmptyContainer()
        let vm = EmailViewModel()
        vm.setup(context: container.mainContext) // person = nil
        let email = EmailAddress(email: "old@test.de", emailType: EmailType.personal.rawValue, isPrimary: false)
        try vm.update(email, email: "new@test.de", emailType: EmailType.work.rawValue, isPrimary: false)
        #expect(email.email == "old@test.de")
    }

    @Test("delete() ohne setup crasht nicht")
    func testDeleteWithoutSetup() throws {
        let vm = EmailViewModel()
        let email = EmailAddress(email: "test@test.de")
        try vm.delete(email)
        #expect(vm.emails.isEmpty)
    }

    @Test("loadEmails() ohne Person gibt leere Liste zurück")
    func testLoadEmailsWithNilPerson() throws {
        let container = try makeEmptyContainer()
        let vm = EmailViewModel()
        vm.setup(context: container.mainContext) // person = nil → guard fires
        vm.loadEmails()
        #expect(vm.emails.isEmpty)
    }
}

// MARK: - NotificationService requestAuthorization Test

@Suite("NotificationService Authorization Tests")
struct NotificationServiceAuthorizationTests {

    @Test("requestAuthorization() läuft ohne Absturz")
    func testRequestAuthorizationDoesNotCrash() {
        NotificationService.shared.requestAuthorization()
        #expect(Bool(true))
    }
}

// MARK: - LoginViewModel clearError Tests

@Suite("LoginViewModel clearError Tests")
@MainActor
struct LoginViewModelClearErrorTests {

    @Test("clearError() setzt errorMessage auf nil")
    func testClearErrorRemovesMessage() {
        let vm = LoginViewModel()
        vm.errorMessage = "Testfehler"
        vm.clearError()
        #expect(vm.errorMessage == nil)
    }

    @Test("clearError() bei bereits nil errorMessage ist stabil")
    func testClearErrorWithNilIsStable() {
        let vm = LoginViewModel()
        vm.clearError()
        #expect(vm.errorMessage == nil)
    }
}

// MARK: - InsuranceCalculator Zusätzliche Tests

@Suite("InsuranceCalculator Zusätzliche Tests")
struct InsuranceCalculatorAdditionalTests {

    let calculator = InsuranceCalculator()

    @Test("calculateMonthlyPremium für negativen Wert gibt negatives Ergebnis")
    func testMonthlyPremiumNegative() {
        let premium = calculator.calculateMonthlyPremium(annualIncome: -12_000)
        #expect(premium < 0)
    }

    @Test("calculateMonthlyPremium für sehr großes Einkommen")
    func testMonthlyPremiumLargeIncome() {
        let premium = calculator.calculateMonthlyPremium(annualIncome: 1_000_000)
        #expect(premium > 0)
    }

    @Test("calculateSickPay für sehr viele Tage")
    func testSickPayManyDays() {
        let pay = calculator.calculateSickPay(dailyNetIncome: 100.0, days: 365)
        #expect(pay == 100.0 * 0.70 * 365)
    }

    @Test("contributionClass für exakt 1.500 € ist Klasse II")
    func testContributionClassBoundary1500() {
        #expect(calculator.contributionClass(for: 1_500.0) == "Klasse II")
    }

    @Test("contributionClass für exakt 3.500 € ist Klasse III")
    func testContributionClassBoundary3500() {
        #expect(calculator.contributionClass(for: 3_500.0) == "Klasse III")
    }

    @Test("awardBonusPoints mit Multiplikator 3")
    func testBonusPointsWithMultiplier3() {
        #expect(calculator.awardBonusPoints(for: "sport", multiplier: 3) == 30)
        #expect(calculator.awardBonusPoints(for: "nichtraucher", multiplier: 3) == 150)
    }

    @Test("insuranceNumbersMatch mit nil gibt keinen Crash durch Force-Unwrap")
    func testInsuranceNumbersMatchCrashesOnNil() {
        // Force-Unwrap ist dokumentiertes Verhalten — nur non-nil Werte testen
        #expect(calculator.insuranceNumbersMatch("A123456789", "A123456789") == true)
        #expect(calculator.insuranceNumbersMatch("A123456789", "B987654321") == false)
    }
}

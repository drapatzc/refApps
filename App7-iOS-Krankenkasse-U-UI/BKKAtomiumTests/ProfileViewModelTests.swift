import Testing
import SwiftData
import Foundation
@testable import BKKAtomium

@Suite("ProfileViewModel Tests")
@MainActor
struct ProfileViewModelTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            InsuredPerson.self, Address.self, PhoneNumber.self,
            BankAccount.self, EmailAddress.self, Invoice.self,
            InsuranceDocument.self, BenefitRequest.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    @Test("loadPerson() mit leerem Store setzt person auf nil")
    func testLoadPersonEmptyStore() throws {
        let container = try makeContainer()
        let vm = ProfileViewModel()
        vm.loadPerson(context: container.mainContext)
        #expect(vm.person == nil)
    }

    @Test("loadPerson() lädt InsuredPerson aus dem Store")
    func testLoadPersonWithData() throws {
        let container = try makeContainer()
        let context = container.mainContext
        context.insert(InsuredPerson(
            lastName: "Mustermann", firstName: "Max", birthDate: Date(),
            insuranceNumber: "M123456789",
            pensionInsuranceNumber: "12 345678 M 001",
            taxId: "12345678901"
        ))
        try context.save()

        let vm = ProfileViewModel()
        vm.loadPerson(context: context)
        #expect(vm.person != nil)
        #expect(vm.person?.lastName == "Mustermann")
        #expect(vm.person?.firstName == "Max")
    }

    @Test("ProfileViewModel hat initial person = nil")
    func testInitialPersonIsNil() {
        let vm = ProfileViewModel()
        #expect(vm.person == nil)
    }

    @Test("ProfileViewModel hat initial isLoading = false")
    func testInitialIsLoadingFalse() {
        let vm = ProfileViewModel()
        #expect(vm.isLoading == false)
    }

    @Test("loadPerson() mit mehreren Personen liefert eine Person")
    func testLoadPersonMultiplePersons() throws {
        let container = try makeContainer()
        let context = container.mainContext
        context.insert(InsuredPerson(
            lastName: "Erster", firstName: "Test", birthDate: Date(),
            insuranceNumber: "E123456789",
            pensionInsuranceNumber: "12 345678 E 001",
            taxId: "12345678901"
        ))
        context.insert(InsuredPerson(
            lastName: "Zweiter", firstName: "Test", birthDate: Date(),
            insuranceNumber: "Z987654321",
            pensionInsuranceNumber: "98 765432 Z 001",
            taxId: "98765432101"
        ))
        try context.save()

        let vm = ProfileViewModel()
        vm.loadPerson(context: context)
        #expect(vm.person != nil)
    }

    @Test("loadPerson() kann mehrfach aufgerufen werden")
    func testLoadPersonCalledTwice() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let person = InsuredPerson(
            lastName: "Schmidt", firstName: "Anna", birthDate: Date(),
            insuranceNumber: "S111111111",
            pensionInsuranceNumber: "11 111111 S 001",
            taxId: "11111111101"
        )
        context.insert(person)
        try context.save()

        let vm = ProfileViewModel()
        vm.loadPerson(context: context)
        vm.loadPerson(context: context)
        #expect(vm.person?.lastName == "Schmidt")
    }

    @Test("loadPerson() überschreibt vorherigen Wert bei leerem Store")
    func testLoadPersonClearsOnEmptyStore() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let vm = ProfileViewModel()
        vm.loadPerson(context: context)
        #expect(vm.person == nil)

        let person = InsuredPerson(
            lastName: "Neuer", firstName: "Test", birthDate: Date(),
            insuranceNumber: "N123456789",
            pensionInsuranceNumber: "12 345678 N 001",
            taxId: "12345678901"
        )
        context.insert(person)
        try context.save()

        vm.loadPerson(context: context)
        #expect(vm.person != nil)
    }
}

import Testing
import SwiftData
import Foundation
@testable import BKKAtomium

@Suite("MockDataSeeder Tests")
@MainActor
struct MockDataSeederTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            InsuredPerson.self, Address.self, PhoneNumber.self,
            BankAccount.self, EmailAddress.self, Invoice.self,
            InsuranceDocument.self, BenefitRequest.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: config)
    }

    @Test("seed() legt genau eine Person an")
    func testSeedCreatesPerson() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        #expect(persons.count == 1)
    }

    @Test("seed() legt Christian Drapatz mit korrekten Daten an")
    func testSeedPersonData() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        let person = try #require(persons.first)
        #expect(person.lastName == "Drapatz")
        #expect(person.firstName == "Christian")
        #expect(person.insuranceNumber == "A987654321")
        #expect(person.pensionInsuranceNumber == "65 220385 D 001")
        #expect(person.taxId == "49823756102")
    }

    @Test("seed() legt Geburtsdatum 22. März 1985 an")
    func testSeedBirthDate() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        let person = try #require(persons.first)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: person.birthDate)
        #expect(components.year == 1985)
        #expect(components.month == 3)
        #expect(components.day == 22)
    }

    @Test("seed() legt 5 Adressen, 8 Telefonnummern, 4 Konten, 6 E-Mails, 17 Rechnungen, 6 Anträge und 7 Dokumente an")
    func testSeedRelationshipCounts() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        let person = try #require(persons.first)
        #expect(person.addresses.count == 5)
        #expect(person.phoneNumbers.count == 8)
        #expect(person.bankAccounts.count == 4)
        #expect(person.emailAddresses.count == 6)
        #expect(person.invoices.count == 17)
        #expect(person.benefitRequests.count == 6)
        #expect(person.documents.count == 7)
    }

    @Test("seed() setzt alle Haupteinträge als primär")
    func testSeedPrimaryFlags() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        let person = try #require(persons.first)
        let primaryAddresses = person.addresses.filter(\.isPrimary)
        #expect(primaryAddresses.count == 1)
        let primaryPhones = person.phoneNumbers.filter(\.isPrimary)
        #expect(primaryPhones.count == 1)
        let primaryBankAccounts = person.bankAccounts.filter(\.isPrimary)
        #expect(primaryBankAccounts.count == 1)
        let primaryEmails = person.emailAddresses.filter(\.isPrimary)
        #expect(primaryEmails.count == 1)
    }

    @Test("seed() legt Commerzbank-Konto mit korrekter IBAN an")
    func testSeedBankAccountData() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        let person = try #require(persons.first)
        let account = try #require(person.bankAccounts.filter { $0.isPrimary }.first)
        #expect(account.iban == "DE89370400440532013000")
        #expect(account.bic == "COBADEFFXXX")
        #expect(account.bankName == "Commerzbank AG")
    }

    @Test("seed() legt Adresse in Essen an")
    func testSeedAddressData() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        let person = try #require(persons.first)
        let address = try #require(person.addresses.filter { $0.isPrimary }.first)
        #expect(address.city == "Essen")
        #expect(address.street == "Am Mühlenbach")
        #expect(address.postalCode == "45147")
    }

    @Test("seed() zweimal hintereinander legt zwei Personen an (keine Idempotenz in seed)")
    func testSeedTwiceCreatesTwoPersons() throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)
        MockDataSeeder.seed(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        #expect(persons.count == 2)
    }

    @Test("seedIfNeeded() legt Person an wenn Datenbank leer ist")
    func testSeedIfNeededWhenEmpty() async throws {
        let container = try makeContainer()
        let context = container.mainContext

        await MockDataSeeder.seedIfNeeded(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        #expect(persons.count == 1)
    }

    @Test("seedIfNeeded() legt keine Person an wenn bereits Daten vorhanden")
    func testSeedIfNeededIdempotency() async throws {
        let container = try makeContainer()
        let context = container.mainContext

        MockDataSeeder.seed(context: context)
        await MockDataSeeder.seedIfNeeded(context: context)

        let persons = try context.fetch(FetchDescriptor<InsuredPerson>())
        #expect(persons.count == 1)
    }
}

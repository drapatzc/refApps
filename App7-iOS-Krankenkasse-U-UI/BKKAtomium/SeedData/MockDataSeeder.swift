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

    /// Inserts a fully populated demo person (Christian Drapatz) with one address,
    /// one phone number, one bank account, and two email addresses.
    ///
    /// Must be called on the main actor because `ModelContext` is not `Sendable`.
    ///
    /// - Parameter context: The `ModelContext` to insert data into.
    @MainActor
    static func seed(context: ModelContext) {
        let calendar = Calendar.current
        let birthDate = calendar.date(from: DateComponents(year: 1985, month: 3, day: 22))!

        let person = InsuredPerson(
            lastName: "Drapatz",
            firstName: "Christian",
            birthDate: birthDate,
            insuranceNumber: "A987654321",
            pensionInsuranceNumber: "65 220385 D 001",
            taxId: "49823756102"
        )
        context.insert(person)

        // Adressen
        let mainAddress = Address(
            street: "Am Mühlenbach",
            houseNumber: "105",
            postalCode: "45147",
            city: "Essen",
            country: "Deutschland",
            addressType: AddressType.primary.rawValue,
            isPrimary: true
        )
        person.addresses.append(mainAddress)

        // Rufnummern
        let mobile = PhoneNumber(
            number: "+49 170 9876543",
            phoneType: PhoneType.mobile.rawValue,
            isPrimary: true
        )
        person.phoneNumbers.append(mobile)

        // Bankverbindung
        let bank = BankAccount(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz",
            isPrimary: true
        )
        person.bankAccounts.append(bank)

        // E-Mail
        let personalEmail = EmailAddress(
            email: "c.drapatz@gmx.de",
            emailType: EmailType.personal.rawValue,
            isPrimary: true
        )
        let workEmail = EmailAddress(
            email: "c.drapatz@handelsblatt.de",
            emailType: EmailType.work.rawValue,
            isPrimary: false
        )
        person.emailAddresses.append(contentsOf: [personalEmail, workEmail])

        try? context.save()
    }
}

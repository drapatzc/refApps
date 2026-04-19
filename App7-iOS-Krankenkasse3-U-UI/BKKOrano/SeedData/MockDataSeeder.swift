import SwiftData
import Foundation

enum MockDataSeeder {

    static func seedIfNeeded(context: ModelContext) async {
        let descriptor = FetchDescriptor<InsuredPerson>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        await MainActor.run {
            seed(context: context)
        }
    }

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

        let mobile = PhoneNumber(
            number: "+49 170 9876543",
            phoneType: PhoneType.mobile.rawValue,
            isPrimary: true
        )
        person.phoneNumbers.append(mobile)

        let bank = BankAccount(
            iban: "DE89370400440532013000",
            bic: "COBADEFFXXX",
            bankName: "Commerzbank AG",
            accountHolder: "Christian Drapatz",
            isPrimary: true
        )
        person.bankAccounts.append(bank)

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

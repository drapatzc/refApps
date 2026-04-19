import SwiftData
import Foundation

/// Aggregate root for a BKK Orano member.
@Model
final class InsuredPerson {

    var id: UUID
    var lastName: String
    var firstName: String
    var birthDate: Date
    var insuranceNumber: String
    var pensionInsuranceNumber: String
    var taxId: String

    @Relationship(deleteRule: .cascade, inverse: \Address.person)
    var addresses: [Address]

    @Relationship(deleteRule: .cascade, inverse: \PhoneNumber.person)
    var phoneNumbers: [PhoneNumber]

    @Relationship(deleteRule: .cascade, inverse: \BankAccount.person)
    var bankAccounts: [BankAccount]

    @Relationship(deleteRule: .cascade, inverse: \EmailAddress.person)
    var emailAddresses: [EmailAddress]

    var fullName: String { "\(firstName) \(lastName)" }

    init(
        id: UUID = UUID(),
        lastName: String,
        firstName: String,
        birthDate: Date,
        insuranceNumber: String,
        pensionInsuranceNumber: String,
        taxId: String
    ) {
        self.id = id
        self.lastName = lastName
        self.firstName = firstName
        self.birthDate = birthDate
        self.insuranceNumber = insuranceNumber
        self.pensionInsuranceNumber = pensionInsuranceNumber
        self.taxId = taxId
        self.addresses = []
        self.phoneNumbers = []
        self.bankAccounts = []
        self.emailAddresses = []
    }
}

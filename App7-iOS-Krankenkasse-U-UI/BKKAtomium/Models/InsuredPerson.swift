import SwiftData
import Foundation

/// A SwiftData model representing a health-insurance member.
///
/// `InsuredPerson` is the aggregate root for all personal data. Its four
/// relationship collections (`addresses`, `phoneNumbers`, `bankAccounts`,
/// `emailAddresses`) are deleted automatically when the person is deleted.
@Model
final class InsuredPerson {

    /// A unique, stable identifier for this person.
    var id: UUID

    /// The person's family name.
    var lastName: String

    /// The person's given (first) name.
    var firstName: String

    /// The person's date of birth.
    var birthDate: Date

    /// The statutory health-insurance number.
    var insuranceNumber: String

    /// The German statutory pension-insurance number (*Rentenversicherungsnummer*).
    var pensionInsuranceNumber: String

    /// The German tax identification number (*Steueridentifikationsnummer*).
    var taxId: String

    /// All addresses associated with this person.
    ///
    /// Cascade-deletes linked `Address` records when the person is deleted.
    @Relationship(deleteRule: .cascade, inverse: \Address.person)
    var addresses: [Address]

    /// All phone numbers associated with this person.
    ///
    /// Cascade-deletes linked `PhoneNumber` records when the person is deleted.
    @Relationship(deleteRule: .cascade, inverse: \PhoneNumber.person)
    var phoneNumbers: [PhoneNumber]

    /// All bank accounts associated with this person.
    ///
    /// Cascade-deletes linked `BankAccount` records when the person is deleted.
    @Relationship(deleteRule: .cascade, inverse: \BankAccount.person)
    var bankAccounts: [BankAccount]

    /// All email addresses associated with this person.
    ///
    /// Cascade-deletes linked `EmailAddress` records when the person is deleted.
    @Relationship(deleteRule: .cascade, inverse: \EmailAddress.person)
    var emailAddresses: [EmailAddress]

    /// The person's full display name, composed from `firstName` and `lastName`.
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    /// Creates a new insured person with the given personal data.
    ///
    /// - Parameters:
    ///   - id: A unique identifier; defaults to a new `UUID`.
    ///   - lastName: The person's family name.
    ///   - firstName: The person's given name.
    ///   - birthDate: The person's date of birth.
    ///   - insuranceNumber: The statutory health-insurance number.
    ///   - pensionInsuranceNumber: The German pension-insurance number.
    ///   - taxId: The German tax identification number.
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

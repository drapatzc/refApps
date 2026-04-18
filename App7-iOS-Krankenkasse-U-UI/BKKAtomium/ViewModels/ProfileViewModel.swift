import SwiftData
import Observation
import SwiftUI

/// Observable view model that loads the top-level `InsuredPerson` for the profile screen.
@Observable
final class ProfileViewModel {

    /// The insured person loaded from the SwiftData store, or `nil` if none exists yet.
    var person: InsuredPerson?

    /// `true` while a fetch operation is in progress.
    var isLoading: Bool = false

    /// Fetches the first `InsuredPerson` from the store and assigns it to `person`.
    ///
    /// - Parameter context: The `ModelContext` to fetch from.
    @MainActor
    func loadPerson(context: ModelContext) {
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
    }
}

/// Observable view model that manages address CRUD operations for the profile screen.
///
/// `AddressViewModel` owns an `AddressRepository` and exposes the current list of
/// addresses together with success/error feedback state.
@Observable
final class AddressViewModel {

    /// The current list of addresses for the person, sorted by priority and city.
    var addresses: [Address] = []

    /// `true` while an operation is in progress.
    var isLoading: Bool = false

    /// An error message to show in the UI, or `nil` when there is no error.
    var errorMessage: String? = nil

    /// Set to `true` briefly after a successful add or update operation.
    var showSuccess: Bool = false

    /// The repository used for persistence.
    private var repository: AddressRepository?

    /// The insured person whose addresses are managed.
    private var person: InsuredPerson?

    /// Initializes the repository and person, then loads the current addresses.
    ///
    /// Must be called on the main actor because `ModelContext` is not `Sendable`.
    ///
    /// - Parameter context: The `ModelContext` to use for all persistence operations.
    @MainActor
    func setup(context: ModelContext) {
        repository = AddressRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadAddresses()
    }

    /// Reloads the address list from the repository.
    func loadAddresses() {
        guard let person else { return }
        addresses = repository?.fetchAll(for: person) ?? []
    }

    /// Adds a new address with the given fields.
    ///
    /// - Parameters:
    ///   - street: The street name.
    ///   - houseNumber: The house or building number.
    ///   - postalCode: The postal code.
    ///   - city: The city name.
    ///   - country: The country name.
    ///   - addressType: The raw value of `AddressType`.
    ///   - isPrimary: Whether this should be the primary address.
    /// - Throws: A `ValidationError` if any field is invalid.
    func add(
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        addressType: String,
        isPrimary: Bool
    ) throws {
        guard let person, let repository else { return }
        try repository.add(
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country,
            addressType: addressType,
            isPrimary: isPrimary,
            to: person
        )
        loadAddresses()
        showSuccess = true
    }

    /// Updates an existing address with the given fields.
    ///
    /// - Parameters:
    ///   - address: The `Address` object to update.
    ///   - street: The new street name.
    ///   - houseNumber: The new house or building number.
    ///   - postalCode: The new postal code.
    ///   - city: The new city name.
    ///   - country: The new country name.
    ///   - addressType: The new raw value of `AddressType`.
    ///   - isPrimary: Whether this should be the primary address.
    /// - Throws: A `ValidationError` if any field is invalid.
    func update(
        _ address: Address,
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        addressType: String,
        isPrimary: Bool
    ) throws {
        guard let person, let repository else { return }
        try repository.update(
            address,
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country,
            addressType: addressType,
            isPrimary: isPrimary,
            person: person
        )
        loadAddresses()
        showSuccess = true
    }

    /// Deletes the given address.
    ///
    /// - Parameter address: The `Address` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ address: Address) throws {
        try repository?.delete(address)
        loadAddresses()
    }
}

/// Observable view model that manages phone-number CRUD operations for the profile screen.
@Observable
final class PhoneNumberViewModel {

    /// The current list of phone numbers for the person, sorted by priority and number string.
    var phones: [PhoneNumber] = []

    /// An error message to show in the UI, or `nil` when there is no error.
    var errorMessage: String? = nil

    /// Set to `true` briefly after a successful add or update operation.
    var showSuccess: Bool = false

    /// The repository used for persistence.
    private var repository: PhoneRepository?

    /// The insured person whose phone numbers are managed.
    private var person: InsuredPerson?

    /// Initializes the repository and person, then loads the current phone numbers.
    ///
    /// - Parameter context: The `ModelContext` to use for all persistence operations.
    @MainActor
    func setup(context: ModelContext) {
        repository = PhoneRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadPhones()
    }

    /// Reloads the phone number list from the repository.
    func loadPhones() {
        guard let person else { return }
        phones = repository?.fetchAll(for: person) ?? []
    }

    /// Adds a new phone number with the given fields.
    ///
    /// - Parameters:
    ///   - number: The phone number string.
    ///   - phoneType: The raw value of `PhoneType`.
    ///   - isPrimary: Whether this should be the primary phone number.
    /// - Throws: A `ValidationError` if the number is invalid.
    func add(number: String, phoneType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.add(number: number, phoneType: phoneType, isPrimary: isPrimary, to: person)
        loadPhones()
        showSuccess = true
    }

    /// Updates an existing phone number with the given fields.
    ///
    /// - Parameters:
    ///   - phone: The `PhoneNumber` object to update.
    ///   - number: The new phone number string.
    ///   - phoneType: The new raw value of `PhoneType`.
    ///   - isPrimary: Whether this should be the primary phone number.
    /// - Throws: A `ValidationError` if the number is invalid.
    func update(_ phone: PhoneNumber, number: String, phoneType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.update(phone, number: number, phoneType: phoneType, isPrimary: isPrimary, person: person)
        loadPhones()
        showSuccess = true
    }

    /// Deletes the given phone number.
    ///
    /// - Parameter phone: The `PhoneNumber` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ phone: PhoneNumber) throws {
        try repository?.delete(phone)
        loadPhones()
    }
}

/// Observable view model that manages bank account CRUD operations for the profile screen.
@Observable
final class BankAccountViewModel {

    /// The current list of bank accounts for the person, sorted by priority and bank name.
    var accounts: [BankAccount] = []

    /// An error message to show in the UI, or `nil` when there is no error.
    var errorMessage: String? = nil

    /// Set to `true` briefly after a successful add or update operation.
    var showSuccess: Bool = false

    /// The repository used for persistence.
    private var repository: BankAccountRepository?

    /// The insured person whose bank accounts are managed.
    private var person: InsuredPerson?

    /// Initializes the repository and person, then loads the current bank accounts.
    ///
    /// - Parameter context: The `ModelContext` to use for all persistence operations.
    @MainActor
    func setup(context: ModelContext) {
        repository = BankAccountRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadAccounts()
    }

    /// Reloads the bank account list from the repository.
    func loadAccounts() {
        guard let person else { return }
        accounts = repository?.fetchAll(for: person) ?? []
    }

    /// Adds a new bank account with the given fields.
    ///
    /// - Parameters:
    ///   - iban: The IBAN string.
    ///   - bic: The BIC string.
    ///   - bankName: The name of the bank.
    ///   - accountHolder: The name of the account holder.
    ///   - isPrimary: Whether this should be the primary account.
    /// - Throws: A `ValidationError` if any field is invalid.
    func add(iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.add(iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder, isPrimary: isPrimary, to: person)
        loadAccounts()
        showSuccess = true
    }

    /// Updates an existing bank account with the given fields.
    ///
    /// - Parameters:
    ///   - account: The `BankAccount` object to update.
    ///   - iban: The new IBAN string.
    ///   - bic: The new BIC string.
    ///   - bankName: The new bank name.
    ///   - accountHolder: The new account holder name.
    ///   - isPrimary: Whether this should be the primary account.
    /// - Throws: A `ValidationError` if any field is invalid.
    func update(_ account: BankAccount, iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.update(account, iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder, isPrimary: isPrimary, person: person)
        loadAccounts()
        showSuccess = true
    }

    /// Deletes the given bank account.
    ///
    /// - Parameter account: The `BankAccount` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ account: BankAccount) throws {
        try repository?.delete(account)
        loadAccounts()
    }
}

/// Observable view model that manages email address CRUD operations for the profile screen.
@Observable
final class EmailViewModel {

    /// The current list of email addresses for the person, sorted by priority and address string.
    var emails: [EmailAddress] = []

    /// An error message to show in the UI, or `nil` when there is no error.
    var errorMessage: String? = nil

    /// Set to `true` briefly after a successful add or update operation.
    var showSuccess: Bool = false

    /// The repository used for persistence.
    private var repository: EmailRepository?

    /// The insured person whose email addresses are managed.
    private var person: InsuredPerson?

    /// Initializes the repository and person, then loads the current email addresses.
    ///
    /// - Parameter context: The `ModelContext` to use for all persistence operations.
    @MainActor
    func setup(context: ModelContext) {
        repository = EmailRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadEmails()
    }

    /// Reloads the email address list from the repository.
    func loadEmails() {
        guard let person else { return }
        emails = repository?.fetchAll(for: person) ?? []
    }

    /// Adds a new email address with the given fields.
    ///
    /// - Parameters:
    ///   - email: The email address string.
    ///   - emailType: The raw value of `EmailType`.
    ///   - isPrimary: Whether this should be the primary email address.
    /// - Throws: A `ValidationError` if the email is invalid.
    func add(email: String, emailType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.add(email: email, emailType: emailType, isPrimary: isPrimary, to: person)
        loadEmails()
        showSuccess = true
    }

    /// Updates an existing email address with the given fields.
    ///
    /// - Parameters:
    ///   - emailAddress: The `EmailAddress` object to update.
    ///   - email: The new email address string.
    ///   - emailType: The new raw value of `EmailType`.
    ///   - isPrimary: Whether this should be the primary email address.
    /// - Throws: A `ValidationError` if the email is invalid.
    func update(_ emailAddress: EmailAddress, email: String, emailType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.update(emailAddress, email: email, emailType: emailType, isPrimary: isPrimary, person: person)
        loadEmails()
        showSuccess = true
    }

    /// Deletes the given email address.
    ///
    /// - Parameter emailAddress: The `EmailAddress` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ emailAddress: EmailAddress) throws {
        try repository?.delete(emailAddress)
        loadEmails()
    }
}

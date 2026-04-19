import SwiftData
import Observation
import SwiftUI

@Observable
final class ProfileViewModel {
    var person: InsuredPerson?
    var isLoading: Bool = false

    @MainActor
    func loadPerson(context: ModelContext) {
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
    }
}

@Observable
final class AddressViewModel {
    var addresses: [Address] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showSuccess: Bool = false

    private var repository: AddressRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = AddressRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadAddresses()
    }

    func loadAddresses() {
        guard let person else { return }
        addresses = repository?.fetchAll(for: person) ?? []
    }

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

    func delete(_ address: Address) throws {
        try repository?.delete(address)
        loadAddresses()
    }
}

@Observable
final class PhoneNumberViewModel {
    var phones: [PhoneNumber] = []
    var errorMessage: String? = nil
    var showSuccess: Bool = false

    private var repository: PhoneRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = PhoneRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadPhones()
    }

    func loadPhones() {
        guard let person else { return }
        phones = repository?.fetchAll(for: person) ?? []
    }

    func add(number: String, phoneType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.add(number: number, phoneType: phoneType, isPrimary: isPrimary, to: person)
        loadPhones()
        showSuccess = true
    }

    func update(_ phone: PhoneNumber, number: String, phoneType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.update(phone, number: number, phoneType: phoneType, isPrimary: isPrimary, person: person)
        loadPhones()
        showSuccess = true
    }

    func delete(_ phone: PhoneNumber) throws {
        try repository?.delete(phone)
        loadPhones()
    }
}

@Observable
final class BankAccountViewModel {
    var accounts: [BankAccount] = []
    var errorMessage: String? = nil
    var showSuccess: Bool = false

    private var repository: BankAccountRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = BankAccountRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadAccounts()
    }

    func loadAccounts() {
        guard let person else { return }
        accounts = repository?.fetchAll(for: person) ?? []
    }

    func add(iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.add(iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder, isPrimary: isPrimary, to: person)
        loadAccounts()
        showSuccess = true
    }

    func update(_ account: BankAccount, iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.update(account, iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder, isPrimary: isPrimary, person: person)
        loadAccounts()
        showSuccess = true
    }

    func delete(_ account: BankAccount) throws {
        try repository?.delete(account)
        loadAccounts()
    }
}

@Observable
final class EmailViewModel {
    var emails: [EmailAddress] = []
    var errorMessage: String? = nil
    var showSuccess: Bool = false

    private var repository: EmailRepository?
    private var person: InsuredPerson?

    @MainActor
    func setup(context: ModelContext) {
        repository = EmailRepository(context: context)
        let descriptor = FetchDescriptor<InsuredPerson>()
        person = try? context.fetch(descriptor).first
        loadEmails()
    }

    func loadEmails() {
        guard let person else { return }
        emails = repository?.fetchAll(for: person) ?? []
    }

    func add(email: String, emailType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.add(email: email, emailType: emailType, isPrimary: isPrimary, to: person)
        loadEmails()
        showSuccess = true
    }

    func update(_ emailAddress: EmailAddress, email: String, emailType: String, isPrimary: Bool) throws {
        guard let person, let repository else { return }
        try repository.update(emailAddress, email: email, emailType: emailType, isPrimary: isPrimary, person: person)
        loadEmails()
        showSuccess = true
    }

    func delete(_ emailAddress: EmailAddress) throws {
        try repository?.delete(emailAddress)
        loadEmails()
    }
}

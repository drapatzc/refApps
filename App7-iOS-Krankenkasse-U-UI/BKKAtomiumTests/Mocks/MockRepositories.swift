import Foundation
import SwiftData
@testable import BKKAtomium

// MARK: - MockAddressRepository

/// Testdouble für `AddressRepositoryProtocol`.
///
/// Speichert Einträge im Arbeitsspeicher — kein SwiftData-Kontext nötig.
/// Ermöglicht deterministische Unit-Tests für ViewModels ohne Persistenz.
final class MockAddressRepository: AddressRepositoryProtocol {

    var stubbedAddresses: [Address] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var updateCallCount: Int = 0
    var deleteCallCount: Int = 0

    func fetchAll(for person: InsuredPerson) -> [Address] {
        stubbedAddresses
    }

    func add(
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        addressType: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func update(
        _ address: Address,
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String,
        addressType: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws {
        updateCallCount += 1
        if let error = thrownError { throw error }
    }

    func delete(_ address: Address) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedAddresses.removeAll { $0.id == address.id }
    }
}

// MARK: - MockPhoneRepository

/// Testdouble für `PhoneRepositoryProtocol`.
final class MockPhoneRepository: PhoneRepositoryProtocol {

    var stubbedPhones: [PhoneNumber] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var updateCallCount: Int = 0
    var deleteCallCount: Int = 0

    func fetchAll(for person: InsuredPerson) -> [PhoneNumber] {
        stubbedPhones
    }

    func add(number: String, phoneType: String, isPrimary: Bool, to person: InsuredPerson) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func update(_ phone: PhoneNumber, number: String, phoneType: String, isPrimary: Bool, person: InsuredPerson) throws {
        updateCallCount += 1
        if let error = thrownError { throw error }
    }

    func delete(_ phone: PhoneNumber) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedPhones.removeAll { $0.id == phone.id }
    }
}

// MARK: - MockEmailRepository

/// Testdouble für `EmailRepositoryProtocol`.
final class MockEmailRepository: EmailRepositoryProtocol {

    var stubbedEmails: [EmailAddress] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var updateCallCount: Int = 0
    var deleteCallCount: Int = 0

    func fetchAll(for person: InsuredPerson) -> [EmailAddress] {
        stubbedEmails
    }

    func add(email: String, emailType: String, isPrimary: Bool, to person: InsuredPerson) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func update(_ emailAddress: EmailAddress, email: String, emailType: String, isPrimary: Bool, person: InsuredPerson) throws {
        updateCallCount += 1
        if let error = thrownError { throw error }
    }

    func delete(_ emailAddress: EmailAddress) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedEmails.removeAll { $0.id == emailAddress.id }
    }
}

// MARK: - MockBankAccountRepository

/// Testdouble für `BankAccountRepositoryProtocol`.
final class MockBankAccountRepository: BankAccountRepositoryProtocol {

    var stubbedAccounts: [BankAccount] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var updateCallCount: Int = 0
    var deleteCallCount: Int = 0

    func fetchAll(for person: InsuredPerson) -> [BankAccount] {
        stubbedAccounts
    }

    func add(iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool, to person: InsuredPerson) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func update(_ account: BankAccount, iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool, person: InsuredPerson) throws {
        updateCallCount += 1
        if let error = thrownError { throw error }
    }

    func delete(_ account: BankAccount) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedAccounts.removeAll { $0.id == account.id }
    }
}

// MARK: - MockInvoiceRepository

/// Testdouble für `InvoiceRepositoryProtocol`.
final class MockInvoiceRepository: InvoiceRepositoryProtocol {

    var stubbedInvoices: [Invoice] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var deleteCallCount: Int = 0

    func fetchAll(for person: InsuredPerson) -> [Invoice] {
        stubbedInvoices
    }

    func fetchFiltered(for person: InsuredPerson, category: InvoiceCategory?, status: InvoiceStatus?) -> [Invoice] {
        stubbedInvoices.filter { invoice in
            (category == nil || invoice.category == category?.rawValue) &&
            (status == nil || invoice.status == status?.rawValue)
        }
    }

    func add(date: Date, amount: Double, provider: String, category: String, status: String, description: String?, to person: InsuredPerson) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func delete(_ invoice: Invoice) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedInvoices.removeAll { $0.id == invoice.id }
    }
}

// MARK: - MockDocumentRepository

/// Testdouble für `DocumentRepositoryProtocol`.
final class MockDocumentRepository: DocumentRepositoryProtocol {

    var stubbedDocuments: [InsuranceDocument] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var deleteCallCount: Int = 0

    func fetchAll(for person: InsuredPerson) -> [InsuranceDocument] {
        stubbedDocuments
    }

    func add(title: String, documentType: String, fileData: Data, notes: String?, to person: InsuredPerson) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func delete(_ document: InsuranceDocument) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedDocuments.removeAll { $0.id == document.id }
    }
}

// MARK: - MockBenefitRequestRepository

/// Testdouble für `BenefitRequestRepositoryProtocol`.
final class MockBenefitRequestRepository: BenefitRequestRepositoryProtocol {

    var stubbedRequests: [BenefitRequest] = []
    var thrownError: Error? = nil
    var addCallCount: Int = 0
    var updateStatusCallCount: Int = 0
    var deleteCallCount: Int = 0
    var lastUpdatedStatus: BenefitRequestStatus?

    func fetchAll(for person: InsuredPerson) -> [BenefitRequest] {
        stubbedRequests
    }

    func add(requestType: String, description: String, amount: Double?, to person: InsuredPerson) throws {
        addCallCount += 1
        if let error = thrownError { throw error }
    }

    func updateStatus(_ request: BenefitRequest, status: BenefitRequestStatus) throws {
        updateStatusCallCount += 1
        lastUpdatedStatus = status
        if let error = thrownError { throw error }
    }

    func delete(_ request: BenefitRequest) throws {
        deleteCallCount += 1
        if let error = thrownError { throw error }
        stubbedRequests.removeAll { $0.id == request.id }
    }
}

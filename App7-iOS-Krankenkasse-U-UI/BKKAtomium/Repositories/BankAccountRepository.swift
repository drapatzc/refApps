import SwiftData
import Foundation

/// Provides CRUD operations for `BankAccount` records associated with an `InsuredPerson`.
///
/// All mutations validate input via `BankAccountValidator` and persist changes by
/// calling `context.save()`. If an account is marked as primary, all other accounts
/// on the same person are demoted. IBAN and BIC are normalized to their canonical
/// forms (no spaces, uppercase) before being stored.
final class BankAccountRepository: BankAccountRepositoryProtocol {

    /// The SwiftData model context used for all persistence operations.
    private let context: ModelContext

    /// Creates a repository backed by the given model context.
    ///
    /// - Parameter context: The `ModelContext` to use for fetch and save operations.
    init(context: ModelContext) {
        self.context = context
    }

    /// Returns all bank accounts for a person, sorted with the primary account first,
    /// then alphabetically by bank name.
    ///
    /// - Parameter person: The insured person whose bank accounts to fetch.
    /// - Returns: A sorted array of `BankAccount` objects.
    func fetchAll(for person: InsuredPerson) -> [BankAccount] {
        person.bankAccounts.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.bankName < rhs.bankName
        }
    }

    /// Validates the provided fields, creates a new `BankAccount`, and appends it
    /// to the person's `bankAccounts` collection.
    ///
    /// If `isPrimary` is `true`, all existing accounts on the person are demoted.
    /// The `BankAccount` initializer normalizes IBAN (removes spaces, uppercases)
    /// and BIC (uppercases) before persisting.
    ///
    /// - Parameters:
    ///   - iban: The IBAN string (may include spaces and mixed case).
    ///   - bic: The BIC string (may be mixed case).
    ///   - bankName: The name of the bank institution.
    ///   - accountHolder: The name of the account holder.
    ///   - isPrimary: Whether the new account should become the primary account.
    ///   - person: The insured person to attach the account to.
    /// - Throws: The first `ValidationError` from `BankAccountValidator` if any field is invalid.
    func add(
        iban: String,
        bic: String,
        bankName: String,
        accountHolder: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws {
        let errors = BankAccountValidator.validate(
            iban: iban,
            bic: bic,
            bankName: bankName,
            accountHolder: accountHolder
        )
        guard errors.isEmpty else { throw errors.first! }

        if isPrimary {
            person.bankAccounts.forEach { $0.isPrimary = false }
        }

        let account = BankAccount(
            iban: iban,
            bic: bic,
            bankName: bankName.trimmingCharacters(in: .whitespaces),
            accountHolder: accountHolder.trimmingCharacters(in: .whitespaces),
            isPrimary: isPrimary
        )
        person.bankAccounts.append(account)
        try context.save()
    }

    /// Validates the provided fields and updates an existing `BankAccount` record.
    ///
    /// If `isPrimary` is `true`, all other accounts on the person (excluding the one
    /// being updated) are demoted. IBAN and BIC are normalized before being stored.
    ///
    /// - Parameters:
    ///   - account: The `BankAccount` object to update.
    ///   - iban: The new IBAN string.
    ///   - bic: The new BIC string.
    ///   - bankName: The new bank name.
    ///   - accountHolder: The new account holder name.
    ///   - isPrimary: Whether this account should become the primary account.
    ///   - person: The insured person who owns this account, used for demotion logic.
    /// - Throws: The first `ValidationError` from `BankAccountValidator` if any field is invalid.
    func update(
        _ account: BankAccount,
        iban: String,
        bic: String,
        bankName: String,
        accountHolder: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws {
        let errors = BankAccountValidator.validate(
            iban: iban,
            bic: bic,
            bankName: bankName,
            accountHolder: accountHolder
        )
        guard errors.isEmpty else { throw errors.first! }

        if isPrimary {
            person.bankAccounts.filter { $0.id != account.id }.forEach { $0.isPrimary = false }
        }

        account.iban = iban.replacingOccurrences(of: " ", with: "").uppercased()
        account.bic = bic.uppercased()
        account.bankName = bankName.trimmingCharacters(in: .whitespaces)
        account.accountHolder = accountHolder.trimmingCharacters(in: .whitespaces)
        account.isPrimary = isPrimary
        try context.save()
    }

    /// Deletes the given bank account from the store.
    ///
    /// - Parameter account: The `BankAccount` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ account: BankAccount) throws {
        context.delete(account)
        try context.save()
    }
}

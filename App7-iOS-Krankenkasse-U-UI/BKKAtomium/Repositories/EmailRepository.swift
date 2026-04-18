import SwiftData
import Foundation

/// Provides CRUD operations for `EmailAddress` records associated with an `InsuredPerson`.
///
/// All mutations validate input via `EmailValidator` and persist changes by
/// calling `context.save()`. If an address is marked as primary, all other email
/// addresses on the same person are demoted. Email strings are trimmed and
/// lowercased before being stored.
final class EmailRepository {

    /// The SwiftData model context used for all persistence operations.
    private let context: ModelContext

    /// Creates a repository backed by the given model context.
    ///
    /// - Parameter context: The `ModelContext` to use for fetch and save operations.
    init(context: ModelContext) {
        self.context = context
    }

    /// Returns all email addresses for a person, sorted with the primary address first,
    /// then alphabetically by email string.
    ///
    /// - Parameter person: The insured person whose email addresses to fetch.
    /// - Returns: A sorted array of `EmailAddress` objects.
    func fetchAll(for person: InsuredPerson) -> [EmailAddress] {
        person.emailAddresses.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.email < rhs.email
        }
    }

    /// Validates the provided fields, creates a new `EmailAddress`, and appends it
    /// to the person's `emailAddresses` collection.
    ///
    /// If `isPrimary` is `true`, all existing email addresses on the person are demoted.
    /// The stored email is trimmed of whitespace and lowercased.
    ///
    /// - Parameters:
    ///   - email: The email address string.
    ///   - emailType: The raw value of `EmailType`.
    ///   - isPrimary: Whether the new address should become the primary email address.
    ///   - person: The insured person to attach the email address to.
    /// - Throws: The first `ValidationError` from `EmailValidator` if the address is invalid.
    func add(
        email: String,
        emailType: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws {
        let errors = EmailValidator.validate(email: email)
        guard errors.isEmpty else { throw errors.first! }

        if isPrimary {
            person.emailAddresses.forEach { $0.isPrimary = false }
        }

        let emailAddr = EmailAddress(
            email: email.trimmingCharacters(in: .whitespaces).lowercased(),
            emailType: emailType,
            isPrimary: isPrimary
        )
        person.emailAddresses.append(emailAddr)
        try context.save()
    }

    /// Validates the provided fields and updates an existing `EmailAddress` record.
    ///
    /// If `isPrimary` is `true`, all other email addresses on the person (excluding
    /// the one being updated) are demoted. The stored email is trimmed and lowercased.
    ///
    /// - Parameters:
    ///   - emailAddress: The `EmailAddress` object to update.
    ///   - email: The new email address string.
    ///   - emailType: The new raw value of `EmailType`.
    ///   - isPrimary: Whether this address should become the primary email address.
    ///   - person: The insured person who owns this address, used for demotion logic.
    /// - Throws: The first `ValidationError` from `EmailValidator` if the address is invalid.
    func update(
        _ emailAddress: EmailAddress,
        email: String,
        emailType: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws {
        let errors = EmailValidator.validate(email: email)
        guard errors.isEmpty else { throw errors.first! }

        if isPrimary {
            person.emailAddresses.filter { $0.id != emailAddress.id }.forEach { $0.isPrimary = false }
        }

        emailAddress.email = email.trimmingCharacters(in: .whitespaces).lowercased()
        emailAddress.emailType = emailType
        emailAddress.isPrimary = isPrimary
        try context.save()
    }

    /// Deletes the given email address from the store.
    ///
    /// - Parameter emailAddress: The `EmailAddress` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ emailAddress: EmailAddress) throws {
        context.delete(emailAddress)
        try context.save()
    }
}

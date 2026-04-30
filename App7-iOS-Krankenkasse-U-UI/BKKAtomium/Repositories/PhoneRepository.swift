import SwiftData
import Foundation

/// Provides CRUD operations for `PhoneNumber` records associated with an `InsuredPerson`.
///
/// All mutations validate input via `PhoneValidator` and persist changes by
/// calling `context.save()`. If a number is marked as primary, all other phone
/// numbers on the same person are demoted.
final class PhoneRepository: PhoneRepositoryProtocol {

    /// The SwiftData model context used for all persistence operations.
    private let context: ModelContext

    /// Creates a repository backed by the given model context.
    ///
    /// - Parameter context: The `ModelContext` to use for fetch and save operations.
    init(context: ModelContext) {
        self.context = context
    }

    /// Returns all phone numbers for a person, sorted with the primary number first,
    /// then alphabetically by number string.
    ///
    /// - Parameter person: The insured person whose phone numbers to fetch.
    /// - Returns: A sorted array of `PhoneNumber` objects.
    func fetchAll(for person: InsuredPerson) -> [PhoneNumber] {
        person.phoneNumbers.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.number < rhs.number
        }
    }

    /// Validates the provided fields, creates a new `PhoneNumber`, and appends it
    /// to the person's `phoneNumbers` collection.
    ///
    /// If `isPrimary` is `true`, all existing phone numbers on the person are demoted.
    ///
    /// - Parameters:
    ///   - number: The phone number string.
    ///   - phoneType: The raw value of `PhoneType`.
    ///   - isPrimary: Whether the new number should become the primary phone number.
    ///   - person: The insured person to attach the number to.
    /// - Throws: The first `ValidationError` from `PhoneValidator` if the number is invalid.
    func add(
        number: String,
        phoneType: String,
        isPrimary: Bool,
        to person: InsuredPerson
    ) throws {
        let errors = PhoneValidator.validate(number: number)
        guard errors.isEmpty else { throw errors.first! }

        if isPrimary {
            person.phoneNumbers.forEach { $0.isPrimary = false }
        }

        let phone = PhoneNumber(
            number: number.trimmingCharacters(in: .whitespaces),
            phoneType: phoneType,
            isPrimary: isPrimary
        )
        person.phoneNumbers.append(phone)
        try context.save()
    }

    /// Validates the provided fields and updates an existing `PhoneNumber` record.
    ///
    /// If `isPrimary` is `true`, all other phone numbers on the person (excluding
    /// the one being updated) are demoted.
    ///
    /// - Parameters:
    ///   - phone: The `PhoneNumber` object to update.
    ///   - number: The new phone number string.
    ///   - phoneType: The new raw value of `PhoneType`.
    ///   - isPrimary: Whether this number should become the primary phone number.
    ///   - person: The insured person who owns this number, used for demotion logic.
    /// - Throws: The first `ValidationError` from `PhoneValidator` if the number is invalid.
    func update(
        _ phone: PhoneNumber,
        number: String,
        phoneType: String,
        isPrimary: Bool,
        person: InsuredPerson
    ) throws {
        let errors = PhoneValidator.validate(number: number)
        guard errors.isEmpty else { throw errors.first! }

        if isPrimary {
            person.phoneNumbers.filter { $0.id != phone.id }.forEach { $0.isPrimary = false }
        }

        phone.number = number.trimmingCharacters(in: .whitespaces)
        phone.phoneType = phoneType
        phone.isPrimary = isPrimary
        try context.save()
    }

    /// Deletes the given phone number from the store.
    ///
    /// - Parameter phone: The `PhoneNumber` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ phone: PhoneNumber) throws {
        context.delete(phone)
        try context.save()
    }
}

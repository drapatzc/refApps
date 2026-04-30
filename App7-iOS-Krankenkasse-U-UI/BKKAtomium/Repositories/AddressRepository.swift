import SwiftData
import Foundation

/// Provides CRUD operations for `Address` records associated with an `InsuredPerson`.
///
/// All mutations validate input via `AddressValidator` and persist changes by
/// calling `context.save()`. If a new or updated address is marked as primary,
/// all other addresses on the same person are demoted.
final class AddressRepository: AddressRepositoryProtocol {

    /// The SwiftData model context used for all persistence operations.
    private let context: ModelContext

    /// Creates a repository backed by the given model context.
    ///
    /// - Parameter context: The `ModelContext` to use for fetch and save operations.
    init(context: ModelContext) {
        self.context = context
    }

    /// Returns all addresses for a person, sorted with the primary address first,
    /// then alphabetically by city.
    ///
    /// - Parameter person: The insured person whose addresses to fetch.
    /// - Returns: A sorted array of `Address` objects.
    func fetchAll(for person: InsuredPerson) -> [Address] {
        person.addresses.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.city < rhs.city
        }
    }

    /// Validates the provided fields, creates a new `Address`, and appends it
    /// to the person's `addresses` collection.
    ///
    /// If `isPrimary` is `true`, all existing addresses on the person are
    /// demoted before the new one is inserted.
    ///
    /// - Parameters:
    ///   - street: The street name.
    ///   - houseNumber: The house or building number.
    ///   - postalCode: The postal code.
    ///   - city: The city name.
    ///   - country: The country name.
    ///   - addressType: The raw value of `AddressType`.
    ///   - isPrimary: Whether the new address should become the primary address.
    ///   - person: The insured person to attach the address to.
    /// - Throws: The first `ValidationError` from `AddressValidator` if any field is invalid.
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
        let errors = AddressValidator.validate(
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country
        )
        guard errors.isEmpty else {
            throw errors.first!
        }

        if isPrimary {
            person.addresses.forEach { $0.isPrimary = false }
        }

        let address = Address(
            street: street.trimmingCharacters(in: .whitespaces),
            houseNumber: houseNumber.trimmingCharacters(in: .whitespaces),
            postalCode: postalCode.trimmingCharacters(in: .whitespaces),
            city: city.trimmingCharacters(in: .whitespaces),
            country: country,
            addressType: addressType,
            isPrimary: isPrimary
        )
        person.addresses.append(address)
        try context.save()
    }

    /// Validates the provided fields and updates an existing `Address` record.
    ///
    /// If `isPrimary` is `true`, all other addresses on the person (excluding the
    /// one being updated) are demoted before the update is applied.
    ///
    /// - Parameters:
    ///   - address: The `Address` object to update.
    ///   - street: The new street name.
    ///   - houseNumber: The new house or building number.
    ///   - postalCode: The new postal code.
    ///   - city: The new city name.
    ///   - country: The new country name.
    ///   - addressType: The new raw value of `AddressType`.
    ///   - isPrimary: Whether this address should become the primary address.
    ///   - person: The insured person who owns this address, used for demotion logic.
    /// - Throws: The first `ValidationError` from `AddressValidator` if any field is invalid.
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
        let errors = AddressValidator.validate(
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country
        )
        guard errors.isEmpty else {
            throw errors.first!
        }

        if isPrimary {
            person.addresses.filter { $0.id != address.id }.forEach { $0.isPrimary = false }
        }

        address.street = street.trimmingCharacters(in: .whitespaces)
        address.houseNumber = houseNumber.trimmingCharacters(in: .whitespaces)
        address.postalCode = postalCode.trimmingCharacters(in: .whitespaces)
        address.city = city.trimmingCharacters(in: .whitespaces)
        address.country = country
        address.addressType = addressType
        address.isPrimary = isPrimary
        try context.save()
    }

    /// Deletes the given address from the store.
    ///
    /// - Parameter address: The `Address` object to delete.
    /// - Throws: A SwiftData error if the save fails.
    func delete(_ address: Address) throws {
        context.delete(address)
        try context.save()
    }
}

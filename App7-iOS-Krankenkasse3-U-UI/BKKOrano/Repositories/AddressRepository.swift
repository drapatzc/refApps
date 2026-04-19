import SwiftData
import Foundation

final class AddressRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func fetchAll(for person: InsuredPerson) -> [Address] {
        person.addresses.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.city < rhs.city
        }
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
        let errors = AddressValidator.validate(
            street: street,
            houseNumber: houseNumber,
            postalCode: postalCode,
            city: city,
            country: country
        )
        guard errors.isEmpty else { throw errors.first! }

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
        guard errors.isEmpty else { throw errors.first! }

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

    func delete(_ address: Address) throws {
        context.delete(address)
        try context.save()
    }
}

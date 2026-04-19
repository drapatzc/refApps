import SwiftData
import Foundation

final class PhoneRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func fetchAll(for person: InsuredPerson) -> [PhoneNumber] {
        person.phoneNumbers.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.number < rhs.number
        }
    }

    func add(number: String, phoneType: String, isPrimary: Bool, to person: InsuredPerson) throws {
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

    func update(_ phone: PhoneNumber, number: String, phoneType: String, isPrimary: Bool, person: InsuredPerson) throws {
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

    func delete(_ phone: PhoneNumber) throws {
        context.delete(phone)
        try context.save()
    }
}

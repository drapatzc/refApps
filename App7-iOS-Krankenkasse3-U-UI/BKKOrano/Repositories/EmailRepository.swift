import SwiftData
import Foundation

final class EmailRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func fetchAll(for person: InsuredPerson) -> [EmailAddress] {
        person.emailAddresses.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.email < rhs.email
        }
    }

    func add(email: String, emailType: String, isPrimary: Bool, to person: InsuredPerson) throws {
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

    func update(_ emailAddress: EmailAddress, email: String, emailType: String, isPrimary: Bool, person: InsuredPerson) throws {
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

    func delete(_ emailAddress: EmailAddress) throws {
        context.delete(emailAddress)
        try context.save()
    }
}

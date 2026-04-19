import SwiftData
import Foundation

final class BankAccountRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func fetchAll(for person: InsuredPerson) -> [BankAccount] {
        person.bankAccounts.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary }
            return lhs.bankName < rhs.bankName
        }
    }

    func add(iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool, to person: InsuredPerson) throws {
        let errors = BankAccountValidator.validate(iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder)
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

    func update(_ account: BankAccount, iban: String, bic: String, bankName: String, accountHolder: String, isPrimary: Bool, person: InsuredPerson) throws {
        let errors = BankAccountValidator.validate(iban: iban, bic: bic, bankName: bankName, accountHolder: accountHolder)
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

    func delete(_ account: BankAccount) throws {
        context.delete(account)
        try context.save()
    }
}

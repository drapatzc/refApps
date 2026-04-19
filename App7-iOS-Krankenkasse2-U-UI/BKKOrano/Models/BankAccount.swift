import SwiftData
import Foundation

@Model
final class BankAccount {
    var id: UUID
    var iban: String
    var bic: String
    var bankName: String
    var accountHolder: String
    var isPrimary: Bool
    var person: InsuredPerson?

    var maskedIBAN: String {
        guard iban.count > 6 else { return iban }
        let prefix = String(iban.prefix(4))
        let suffix = String(iban.suffix(4))
        let masked = String(repeating: "•", count: iban.count - 8)
        return "\(prefix) \(masked) \(suffix)"
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var formattedIBAN: String {
        var result = ""
        let cleaned = iban.replacingOccurrences(of: " ", with: "")
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 { result += " " }
            result += String(char)
        }
        return result
    }

    init(
        id: UUID = UUID(),
        iban: String,
        bic: String,
        bankName: String,
        accountHolder: String,
        isPrimary: Bool = false
    ) {
        self.id = id
        self.iban = iban.replacingOccurrences(of: " ", with: "").uppercased()
        self.bic = bic.uppercased()
        self.bankName = bankName
        self.accountHolder = accountHolder
        self.isPrimary = isPrimary
    }
}

import SwiftData
import Foundation

/// A SwiftData model representing a bank account linked to an `InsuredPerson`.
///
/// The `init` normalizes IBAN (removes spaces, uppercases) and BIC (uppercases)
/// immediately, so stored values are always in canonical form.
@Model
final class BankAccount {

    /// A unique, stable identifier for this bank account.
    var id: UUID

    /// The International Bank Account Number in canonical form (no spaces, uppercase).
    var iban: String

    /// The Bank Identifier Code in uppercase.
    var bic: String

    /// The name of the bank institution.
    var bankName: String

    /// The name of the account holder.
    var accountHolder: String

    /// Whether this is the person's primary bank account.
    var isPrimary: Bool

    /// The `InsuredPerson` this bank account belongs to.
    var person: InsuredPerson?

    /// A display-safe IBAN that shows only the first 4 and last 4 characters;
    /// all intermediate digits are replaced with bullet characters.
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

    /// The IBAN formatted with a space after every four characters for readability.
    var formattedIBAN: String {
        var result = ""
        let cleaned = iban.replacingOccurrences(of: " ", with: "")
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result += String(char)
        }
        return result
    }

    /// Creates a new bank account record.
    ///
    /// The IBAN is normalized (spaces removed, uppercased) and the BIC is uppercased
    /// before being stored.
    ///
    /// - Parameters:
    ///   - id: A unique identifier; defaults to a new `UUID`.
    ///   - iban: The IBAN string (may include spaces and mixed case).
    ///   - bic: The BIC string (may be mixed case).
    ///   - bankName: The name of the bank.
    ///   - accountHolder: The name of the account holder.
    ///   - isPrimary: Whether this is the primary account; defaults to `false`.
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

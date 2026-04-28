import Foundation

// MARK: - Validierungsfehler

/// A validation error that can be produced by any of the app's validators.
///
/// Each case carries field-specific context (field name, limits) so that
/// error messages can be fully localized at the call site.
enum ValidationError: Error, LocalizedError, Equatable {

    /// A required field is empty.
    case empty(field: String)

    /// A field value is shorter than the required minimum.
    case tooShort(field: String, minimum: Int)

    /// A field value exceeds the allowed maximum length.
    case tooLong(field: String, maximum: Int)

    /// A field value does not match the expected format.
    case invalidFormat(field: String)

    /// The IBAN failed the modulo-97 checksum or structural validation.
    case invalidIBAN

    /// The BIC does not match the standard pattern.
    case invalidBIC

    /// The email address does not match the RFC-style pattern.
    case invalidEmail

    /// The phone number contains illegal characters or is outside the allowed length range.
    case invalidPhoneNumber

    /// The postal code is not valid for the given country.
    case invalidPostalCode

    /// More than one entry is marked as primary in a collection where only one is allowed.
    case duplicatePrimary

    /// A localized description of the error, suitable for display in the UI.
    var errorDescription: String? {
        switch self {
        case .empty(let field):
            return String(format: String(localized: "validation_empty"), field)
        case .tooShort(let field, let min):
            return String(format: String(localized: "validation_too_short"), field, min)
        case .tooLong(let field, let max):
            return String(format: String(localized: "validation_too_long"), field, max)
        case .invalidFormat(let field):
            return String(format: String(localized: "validation_invalid_format"), field)
        case .invalidIBAN:
            return String(localized: "validation_invalid_iban")
        case .invalidBIC:
            return String(localized: "validation_invalid_bic")
        case .invalidEmail:
            return String(localized: "validation_invalid_email")
        case .invalidPhoneNumber:
            return String(localized: "validation_invalid_phone")
        case .invalidPostalCode:
            return String(localized: "validation_invalid_postal_code")
        case .duplicatePrimary:
            return String(localized: "validation_duplicate_primary")
        }
    }
}

// MARK: - Address Validator

/// A stateless validator for postal address fields.
struct AddressValidator {

    /// Validates all required address fields and returns a list of errors.
    ///
    /// Checks that street, house number, city, and country are non-empty and
    /// within allowed lengths. Validates the postal code format based on the
    /// country (5-digit numeric for Germany; 3–10 characters otherwise).
    ///
    /// - Parameters:
    ///   - street: The street name to validate.
    ///   - houseNumber: The house or building number to validate.
    ///   - postalCode: The postal code to validate.
    ///   - city: The city name to validate.
    ///   - country: The country name, used to select the postal-code format rule.
    /// - Returns: An array of `ValidationError` values; empty if all fields are valid.
    static func validate(
        street: String,
        houseNumber: String,
        postalCode: String,
        city: String,
        country: String
    ) -> [ValidationError] {
        var errors: [ValidationError] = []

        if street.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_street")))
        } else if street.count > 100 {
            errors.append(.tooLong(field: String(localized: "field_street"), maximum: 100))
        }

        if houseNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_house_number")))
        } else if houseNumber.count > 10 {
            errors.append(.tooLong(field: String(localized: "field_house_number"), maximum: 10))
        }

        if postalCode.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_postal_code")))
        } else if !isValidPostalCode(postalCode, country: country) {
            errors.append(.invalidPostalCode)
        }

        if city.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_city")))
        } else if city.count > 100 {
            errors.append(.tooLong(field: String(localized: "field_city"), maximum: 100))
        }

        if country.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_country")))
        }

        return errors
    }

    /// Validates a postal code for the given country.
    ///
    /// German postal codes must be exactly 5 decimal digits. For all other countries
    /// a length of 3–10 non-empty characters is accepted.
    ///
    /// - Parameters:
    ///   - code: The postal code string.
    ///   - country: The country name.
    /// - Returns: `true` if the code is valid for the country.
    private static func isValidPostalCode(_ code: String, country: String) -> Bool {
        let cleaned = code.trimmingCharacters(in: .whitespaces)
        if country == "Deutschland" || country == "Germany" {
            return cleaned.count == 5 && cleaned.allSatisfy(\.isNumber)
        }
        return !cleaned.isEmpty && cleaned.count >= 3 && cleaned.count <= 10
    }
}

// MARK: - Phone Validator

/// A stateless validator for phone number strings.
struct PhoneValidator {

    /// Validates a phone number string and returns a list of errors.
    ///
    /// Checks that the trimmed number is non-empty, between 6 and 20 characters,
    /// and contains only digits plus the characters `+`, `-`, ` `, `(`, `)`.
    ///
    /// - Parameter number: The phone number string to validate.
    /// - Returns: An array of `ValidationError` values; empty if the number is valid.
    static func validate(number: String) -> [ValidationError] {
        var errors: [ValidationError] = []

        let trimmed = number.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            errors.append(.empty(field: String(localized: "field_phone_number")))
            return errors
        }

        if trimmed.count < 6 {
            errors.append(.tooShort(field: String(localized: "field_phone_number"), minimum: 6))
        }

        if trimmed.count > 20 {
            errors.append(.tooLong(field: String(localized: "field_phone_number"), maximum: 20))
        }

        let allowedChars = CharacterSet.decimalDigits
            .union(CharacterSet(charactersIn: "+ -()"))
        if !trimmed.unicodeScalars.allSatisfy({ allowedChars.contains($0) }) {
            errors.append(.invalidPhoneNumber)
        }

        return errors
    }
}

// MARK: - Email Validator

/// A stateless validator for email address strings.
struct EmailValidator {

    /// Validates an email address string and returns a list of errors.
    ///
    /// Checks that the trimmed address is non-empty, matches the RFC-style
    /// pattern enforced by `isValidEmail(_:)`, and does not exceed 254 characters.
    ///
    /// - Parameter email: The email address string to validate.
    /// - Returns: An array of `ValidationError` values; empty if the address is valid.
    static func validate(email: String) -> [ValidationError] {
        var errors: [ValidationError] = []

        let trimmed = email.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            errors.append(.empty(field: String(localized: "field_email")))
            return errors
        }

        if !isValidEmail(trimmed) {
            errors.append(.invalidEmail)
        }

        if trimmed.count > 254 {
            errors.append(.tooLong(field: String(localized: "field_email"), maximum: 254))
        }

        return errors
    }

    /// Returns whether the given string matches the app's email-format pattern.
    ///
    /// The pattern requires a local part, an `@` sign, a domain with at least one
    /// dot, and a top-level domain of at least two characters.
    ///
    /// - Parameter email: The trimmed email address string.
    /// - Returns: `true` if the string matches the pattern.
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - BankAccount Validator

/// A stateless validator for bank account fields (IBAN, BIC, bank name, account holder).
struct BankAccountValidator {

    /// Validates all required bank account fields and returns a list of errors.
    ///
    /// - Parameters:
    ///   - iban: The IBAN string (may include spaces).
    ///   - bic: The BIC string.
    ///   - bankName: The name of the bank.
    ///   - accountHolder: The name of the account holder.
    /// - Returns: An array of `ValidationError` values; empty if all fields are valid.
    static func validate(
        iban: String,
        bic: String,
        bankName: String,
        accountHolder: String
    ) -> [ValidationError] {
        var errors: [ValidationError] = []

        let cleanedIBAN = iban.replacingOccurrences(of: " ", with: "").uppercased()

        if cleanedIBAN.isEmpty {
            errors.append(.empty(field: "IBAN"))
        } else if !isValidIBAN(cleanedIBAN) {
            errors.append(.invalidIBAN)
        }

        let cleanedBIC = bic.trimmingCharacters(in: .whitespaces).uppercased()
        if cleanedBIC.isEmpty {
            errors.append(.empty(field: "BIC"))
        } else if !isValidBIC(cleanedBIC) {
            errors.append(.invalidBIC)
        }

        if bankName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_bank_name")))
        }

        if accountHolder.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_account_holder")))
        } else if accountHolder.count > 100 {
            errors.append(.tooLong(field: String(localized: "field_account_holder"), maximum: 100))
        }

        return errors
    }

    /// Validates an IBAN using structural checks and the ISO 7064 modulo-97 checksum.
    ///
    /// - Parameter iban: The IBAN in canonical form (no spaces, uppercase).
    /// - Returns: `true` if the IBAN is structurally valid and passes the checksum.
    static func isValidIBAN(_ iban: String) -> Bool {
        let cleaned = iban.replacingOccurrences(of: " ", with: "").uppercased()
        guard cleaned.count >= 15 && cleaned.count <= 34 else { return false }

        let countryCode = String(cleaned.prefix(2))
        guard countryCode.allSatisfy(\.isLetter) else { return false }

        guard cleaned.dropFirst(2).prefix(2).allSatisfy(\.isNumber) else { return false }

        let rearranged = String(cleaned.dropFirst(4)) + String(cleaned.prefix(4))
        let numericString = rearranged.compactMap { char -> String? in
            if let digit = char.wholeNumberValue {
                return String(digit)
            } else if char.isLetter {
                return String(char.asciiValue! - 55)
            }
            return nil
        }.joined()

        var remainder = 0
        for char in numericString {
            remainder = (remainder * 10 + Int(String(char))!) % 97
        }
        return remainder == 1
    }

    /// Validates a BIC against the standard 8- or 11-character pattern.
    ///
    /// The pattern requires 6 uppercase letters, 2 alphanumeric characters,
    /// and an optional 3-character branch code.
    ///
    /// - Parameter bic: The BIC in uppercase.
    /// - Returns: `true` if the BIC matches the standard pattern.
    static func isValidBIC(_ bic: String) -> Bool {
        let pattern = #"^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$"#
        return bic.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Invoice Validator

struct InvoiceValidator {
    static func validate(date: Date, amount: Double, provider: String) -> [ValidationError] {
        var errors: [ValidationError] = []

        let trimmedProvider = provider.trimmingCharacters(in: .whitespaces)
        if trimmedProvider.isEmpty {
            errors.append(.empty(field: String(localized: "field_provider")))
        }

        if amount <= 0 {
            errors.append(.invalidFormat(field: String(localized: "field_amount")))
        }

        return errors
    }
}

// MARK: - Document Validator

struct DocumentValidator {
    static let maxFileSize = 10 * 1024 * 1024

    static func validate(title: String, fileData: Data) -> [ValidationError] {
        var errors: [ValidationError] = []

        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_document_title")))
        }

        if fileData.isEmpty {
            errors.append(.empty(field: String(localized: "field_document_file")))
        } else if fileData.count > maxFileSize {
            errors.append(.tooLong(field: String(localized: "field_document_file"), maximum: 10))
        }

        return errors
    }
}

// MARK: - BenefitRequest Validator

struct BenefitRequestValidator {
    static func validate(description: String) -> [ValidationError] {
        var errors: [ValidationError] = []

        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.empty(field: String(localized: "field_description")))
        }

        return errors
    }
}

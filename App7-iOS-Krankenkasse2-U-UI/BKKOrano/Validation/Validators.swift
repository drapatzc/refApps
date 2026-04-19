import Foundation

// MARK: - Validation Error

enum ValidationError: Error, LocalizedError, Equatable {
    case empty(field: String)
    case tooShort(field: String, minimum: Int)
    case tooLong(field: String, maximum: Int)
    case invalidFormat(field: String)
    case invalidIBAN
    case invalidBIC
    case invalidEmail
    case invalidPhoneNumber
    case invalidPostalCode
    case duplicatePrimary

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

struct AddressValidator {

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

    private static func isValidPostalCode(_ code: String, country: String) -> Bool {
        let cleaned = code.trimmingCharacters(in: .whitespaces)
        if country == "Deutschland" || country == "Germany" {
            return cleaned.count == 5 && cleaned.allSatisfy(\.isNumber)
        }
        return !cleaned.isEmpty && cleaned.count >= 3 && cleaned.count <= 10
    }
}

// MARK: - Phone Validator

struct PhoneValidator {

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

struct EmailValidator {

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

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - BankAccount Validator

struct BankAccountValidator {

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

    static func isValidBIC(_ bic: String) -> Bool {
        let pattern = #"^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$"#
        return bic.range(of: pattern, options: .regularExpression) != nil
    }
}

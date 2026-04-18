import Foundation

/// Validation logic for user data
struct UserValidator {

    // MARK: - Maximum Lengths
    static let maxNameLength = 100
    static let maxStreetLength = 200
    static let maxPostalCodeLength = 10
    static let minPostalCodeLength = 3
    static let maxCityLength = 100
    static let maxCountryLength = 100
    static let maxEmailLength = 254

    // MARK: - Main Validation

    func validate(_ user: User) -> ValidationResult {
        var errors: [ValidationFieldError] = []

        // Salutation
        if let error = validateSalutation(user.salutation) {
            errors.append(error)
        }

        // First name
        if let error = validateFirstName(user.firstName) {
            errors.append(error)
        }

        // Last name
        if let error = validateLastName(user.lastName) {
            errors.append(error)
        }

        // Street
        if let error = validateStreet(user.street) {
            errors.append(error)
        }

        // House number
        if let error = validateHouseNumber(user.houseNumber) {
            errors.append(error)
        }

        // Postal code
        if let error = validatePostalCode(user.postalCode) {
            errors.append(error)
        }

        // City
        if let error = validateCity(user.city) {
            errors.append(error)
        }

        // Country
        if let error = validateCountry(user.country) {
            errors.append(error)
        }

        // Email (optional — only validate when not empty)
        if let error = validateEmail(user.email) {
            errors.append(error)
        }

        return errors.isEmpty ? .valid : .invalid(errors)
    }

    // MARK: - Individual Field Validations

    func validateSalutation(_ salutation: Salutation) -> ValidationFieldError? {
        // Salutation is an enum — always valid
        return nil
    }

    func validateFirstName(_ firstName: String) -> ValidationFieldError? {
        let trimmed = firstName.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .firstName,
                message: String(localized: "validation_required_first_name")
            )
        }
        if trimmed.count > Self.maxNameLength {
            return ValidationFieldError(
                field: .firstName,
                message: String(format: String(localized: "validation_max_length"), Self.maxNameLength)
            )
        }
        return nil
    }

    func validateLastName(_ lastName: String) -> ValidationFieldError? {
        let trimmed = lastName.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .lastName,
                message: String(localized: "validation_required_last_name")
            )
        }
        if trimmed.count > Self.maxNameLength {
            return ValidationFieldError(
                field: .lastName,
                message: String(format: String(localized: "validation_max_length"), Self.maxNameLength)
            )
        }
        return nil
    }

    func validateStreet(_ street: String) -> ValidationFieldError? {
        let trimmed = street.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .street,
                message: String(localized: "validation_required_street")
            )
        }
        if trimmed.count > Self.maxStreetLength {
            return ValidationFieldError(
                field: .street,
                message: String(format: String(localized: "validation_max_length"), Self.maxStreetLength)
            )
        }
        return nil
    }

    func validateHouseNumber(_ houseNumber: String) -> ValidationFieldError? {
        let trimmed = houseNumber.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .houseNumber,
                message: String(localized: "validation_required_house_number")
            )
        }
        return nil
    }

    func validatePostalCode(_ postalCode: String) -> ValidationFieldError? {
        let trimmed = postalCode.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .postalCode,
                message: String(localized: "validation_required_postal_code")
            )
        }
        // Digits only
        let digitsOnly = CharacterSet.decimalDigits
        if !trimmed.unicodeScalars.allSatisfy({ digitsOnly.contains($0) }) {
            return ValidationFieldError(
                field: .postalCode,
                message: String(localized: "validation_postal_code_digits_only")
            )
        }
        // Length 3–10
        if trimmed.count < Self.minPostalCodeLength || trimmed.count > Self.maxPostalCodeLength {
            return ValidationFieldError(
                field: .postalCode,
                message: String(format: String(localized: "validation_postal_code_length"),
                                Self.minPostalCodeLength, Self.maxPostalCodeLength)
            )
        }
        return nil
    }

    func validateCity(_ city: String) -> ValidationFieldError? {
        let trimmed = city.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .city,
                message: String(localized: "validation_required_city")
            )
        }
        if trimmed.count > Self.maxCityLength {
            return ValidationFieldError(
                field: .city,
                message: String(format: String(localized: "validation_max_length"), Self.maxCityLength)
            )
        }
        return nil
    }

    func validateCountry(_ country: String) -> ValidationFieldError? {
        let trimmed = country.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ValidationFieldError(
                field: .country,
                message: String(localized: "validation_required_country")
            )
        }
        if trimmed.count > Self.maxCountryLength {
            return ValidationFieldError(
                field: .country,
                message: String(format: String(localized: "validation_max_length"), Self.maxCountryLength)
            )
        }
        return nil
    }

    func validateEmail(_ email: String) -> ValidationFieldError? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        // Email is optional — no error when empty
        if trimmed.isEmpty { return nil }

        if trimmed.count > Self.maxEmailLength {
            return ValidationFieldError(
                field: .email,
                message: String(format: String(localized: "validation_max_length"), Self.maxEmailLength)
            )
        }

        // RFC-compliant regex pattern
        let emailPattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let regex = try? NSRegularExpression(pattern: emailPattern)
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        if regex?.firstMatch(in: trimmed, range: range) == nil {
            return ValidationFieldError(
                field: .email,
                message: String(localized: "validation_email_invalid")
            )
        }
        return nil
    }
}

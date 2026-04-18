import Foundation

/// Result of a validation
enum ValidationResult {
    case valid
    case invalid([ValidationFieldError])

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var errors: [ValidationFieldError] {
        if case .invalid(let errors) = self { return errors }
        return []
    }

    /// Error for a specific field
    func error(for field: UserField) -> String? {
        errors.first(where: { $0.field == field })?.message
    }
}

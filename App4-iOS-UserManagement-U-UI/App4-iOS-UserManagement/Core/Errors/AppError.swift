import Foundation

/// All error cases of the app
enum AppError: LocalizedError, Equatable {
    // MARK: - Database Errors
    case databaseOpenFailed(String)
    case databaseQueryFailed(String)
    case databaseInsertFailed(String)
    case databaseUpdateFailed(String)
    case databaseDeleteFailed(String)
    case recordNotFound

    // MARK: - Validation Errors
    case validationFailed([ValidationFieldError])

    // MARK: - General Errors
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .databaseOpenFailed(let msg):
            return String(localized: "error_db_open") + ": \(msg)"
        case .databaseQueryFailed(let msg):
            return String(localized: "error_db_query") + ": \(msg)"
        case .databaseInsertFailed(let msg):
            return String(localized: "error_db_insert") + ": \(msg)"
        case .databaseUpdateFailed(let msg):
            return String(localized: "error_db_update") + ": \(msg)"
        case .databaseDeleteFailed(let msg):
            return String(localized: "error_db_delete") + ": \(msg)"
        case .recordNotFound:
            return String(localized: "error_record_not_found")
        case .validationFailed(let errors):
            return errors.map { $0.message }.joined(separator: "\n")
        case .unknown(let msg):
            return String(localized: "error_unknown") + ": \(msg)"
        }
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.databaseOpenFailed(let a), .databaseOpenFailed(let b)): return a == b
        case (.databaseQueryFailed(let a), .databaseQueryFailed(let b)): return a == b
        case (.databaseInsertFailed(let a), .databaseInsertFailed(let b)): return a == b
        case (.databaseUpdateFailed(let a), .databaseUpdateFailed(let b)): return a == b
        case (.databaseDeleteFailed(let a), .databaseDeleteFailed(let b)): return a == b
        case (.recordNotFound, .recordNotFound): return true
        case (.validationFailed(let a), .validationFailed(let b)): return a == b
        case (.unknown(let a), .unknown(let b)): return a == b
        default: return false
        }
    }
}

/// Single validation error for a specific field
struct ValidationFieldError: Equatable {
    let field: UserField
    let message: String
}

/// Fields of the user form
enum UserField: String, CaseIterable {
    case salutation
    case firstName
    case lastName
    case street
    case houseNumber
    case postalCode
    case city
    case country
    case email

    var localizedLabel: String {
        switch self {
        case .salutation: return String(localized: "field_salutation")
        case .firstName: return String(localized: "field_first_name")
        case .lastName: return String(localized: "field_last_name")
        case .street: return String(localized: "field_street")
        case .houseNumber: return String(localized: "field_house_number")
        case .postalCode: return String(localized: "field_postal_code")
        case .city: return String(localized: "field_city")
        case .country: return String(localized: "field_country")
        case .email: return String(localized: "field_email")
        }
    }
}

import Foundation

final class AuthService {
    static let shared = AuthService()

    private let validPasswords: Set<String> = ["123456", "Abc12345#", "testmann"]

    private init() {}

    func login(password: String) -> Bool {
        validPasswords.contains(password)
    }

    func validatePassword(_ password: String) -> AuthError? {
        if password.isEmpty { return .emptyPassword }
        if !validPasswords.contains(password) { return .invalidCredentials }
        return nil
    }
}

enum AuthError: Error, LocalizedError {
    case emptyPassword
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .emptyPassword: String(localized: "auth_error_empty_password")
        case .invalidCredentials: String(localized: "auth_error_invalid_credentials")
        }
    }
}

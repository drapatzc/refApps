import Foundation

/// A singleton service that performs password-based authentication.
///
/// `AuthService` holds a hard-coded set of valid passwords and exposes
/// methods to verify them. In a production app these would be replaced
/// by a secure server-side authentication flow.
final class AuthService {

    /// The shared singleton instance.
    static let shared = AuthService()

    /// The set of accepted passwords (for demo purposes only).
    private let validPasswords: Set<String> = ["123456", "Abc12345#", "testmann"]

    private init() {}

    /// Returns `true` if the given password is in the accepted set.
    ///
    /// - Parameter password: The plaintext password to check.
    /// - Returns: `true` for a valid password, `false` otherwise.
    func login(password: String) -> Bool {
        return validPasswords.contains(password)
    }

    /// Validates a password and returns the first applicable error, or `nil` on success.
    ///
    /// - Parameter password: The plaintext password to validate.
    /// - Returns: `.emptyPassword` if the string is empty, `.invalidCredentials` if it
    ///   is not in the accepted set, or `nil` if the password is valid.
    func validatePassword(_ password: String) -> AuthError? {
        if password.isEmpty {
            return .emptyPassword
        }
        if !validPasswords.contains(password) {
            return .invalidCredentials
        }
        return nil
    }
}

/// Errors that can occur during the authentication flow.
enum AuthError: Error, LocalizedError {

    /// The supplied password string was empty.
    case emptyPassword

    /// The supplied password was not accepted.
    case invalidCredentials

    /// A localized description suitable for display in the UI.
    var errorDescription: String? {
        switch self {
        case .emptyPassword:
            return String(localized: "auth_error_empty_password")
        case .invalidCredentials:
            return String(localized: "auth_error_invalid_credentials")
        }
    }
}

import SwiftUI
import Observation

/// Observable view model that drives the login screen.
///
/// `LoginViewModel` coordinates input validation, the asynchronous login flow,
/// and UI state (loading indicator, error display). It delegates the actual
/// credential check to `AuthService`.
@Observable
final class LoginViewModel {

    /// The plaintext password entered by the user.
    var password: String = ""

    /// `true` while the login request is in progress.
    var isLoading: Bool = false

    /// An error message to show in the UI, or `nil` when there is no error.
    var errorMessage: String? = nil

    /// Set to `true` after a successful login so the parent view can react.
    var loginSucceeded: Bool = false

    /// The authentication service used to validate credentials.
    private let authService: AuthService

    /// Creates a view model with the given authentication service.
    ///
    /// - Parameter authService: The service to use for credential validation;
    ///   defaults to the shared singleton.
    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    /// `true` when the login button should be interactive:
    /// the password field is non-empty and no request is currently in flight.
    var isLoginButtonEnabled: Bool {
        !password.isEmpty && !isLoading
    }

    /// Attempts to log in with the current `password`.
    ///
    /// Sets `isLoading` to `true`, waits 600 ms (for realistic UX feel), then
    /// delegates to `authService.login(password:)`. On failure the password field
    /// is cleared with a spring animation and `errorMessage` is set. On success
    /// `loginSucceeded` is set to `true`.
    @MainActor
    func login() async {
        guard !password.isEmpty else {
            errorMessage = AuthError.emptyPassword.errorDescription
            return
        }

        isLoading = true
        errorMessage = nil

        // Kurze Verzögerung für realistische UX
        try? await Task.sleep(for: .milliseconds(600))

        let success = authService.login(password: password)

        if success {
            loginSucceeded = true
        } else {
            errorMessage = AuthError.invalidCredentials.errorDescription
            isLoading = false

            // Passwort nach Fehler leeren
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                password = ""
            }
        }
    }

    /// Clears the current error message.
    func clearError() {
        errorMessage = nil
    }
}

import SwiftUI
import Observation

@Observable
final class LoginViewModel {
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var loginSucceeded: Bool = false

    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    var isLoginButtonEnabled: Bool {
        !password.isEmpty && !isLoading
    }

    @MainActor
    func login() async {
        guard !password.isEmpty else {
            errorMessage = AuthError.emptyPassword.errorDescription
            return
        }

        isLoading = true
        errorMessage = nil

        try? await Task.sleep(for: .milliseconds(600))

        let success = authService.login(password: password)

        if success {
            loginSucceeded = true
        } else {
            errorMessage = AuthError.invalidCredentials.errorDescription
            isLoading = false

            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                password = ""
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

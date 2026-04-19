import Testing
@testable import BKKOrano

// MARK: - AuthService

@Suite("AuthService")
struct AuthServiceTests {

    @Test("Accepts valid demo passwords")
    func acceptsValidPasswords() {
        #expect(AuthService.shared.login(password: "123456"))
        #expect(AuthService.shared.login(password: "Abc12345#"))
        #expect(AuthService.shared.login(password: "testmann"))
    }

    @Test("Rejects incorrect passwords")
    func rejectsInvalidPasswords() {
        #expect(AuthService.shared.login(password: "") == false)
        #expect(AuthService.shared.login(password: "123") == false)
        #expect(AuthService.shared.login(password: "ABC12345#") == false)  // case-sensitive
    }

    @Test("Empty password validation returns emptyPassword")
    func emptyPasswordValidation() {
        #expect(AuthService.shared.validatePassword("") == .emptyPassword)
    }

    @Test("Invalid password validation returns invalidCredentials")
    func invalidPasswordValidation() {
        #expect(AuthService.shared.validatePassword("not-a-real-pw") == .invalidCredentials)
    }

    @Test("Valid password returns no error")
    func validPasswordReturnsNoError() {
        #expect(AuthService.shared.validatePassword("testmann") == nil)
    }
}

// MARK: - LoginViewModel

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {

    @Test("Button disabled with empty password")
    func buttonDisabledWhenEmpty() {
        let vm = LoginViewModel()
        #expect(vm.isLoginButtonEnabled == false)
    }

    @Test("Button enabled when password entered")
    func buttonEnabledWhenPopulated() {
        let vm = LoginViewModel()
        vm.password = "anything"
        #expect(vm.isLoginButtonEnabled)
    }

    @Test("Initial state is clean")
    func initialStateIsClean() {
        let vm = LoginViewModel()
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
        #expect(vm.loginSucceeded == false)
    }

    @Test("clearError wipes the error message")
    func clearErrorWorks() {
        let vm = LoginViewModel()
        vm.errorMessage = "Something"
        vm.clearError()
        #expect(vm.errorMessage == nil)
    }
}

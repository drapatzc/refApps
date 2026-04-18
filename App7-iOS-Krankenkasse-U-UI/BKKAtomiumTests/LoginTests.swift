import Testing
@testable import BKKAtomium

// MARK: - AuthService Tests

/// Unit tests for `AuthService`, verifying the acceptance of valid passwords,
/// the rejection of invalid passwords, and the correct error types returned by `validatePassword(_:)`.
@Suite("Authentication Tests")
struct AuthServiceTests {

    /// The system under test — the shared `AuthService` singleton.
    let sut = AuthService.shared

    /// Verifies that all demo passwords configured in `AuthService` are accepted by `login(password:)`.
    @Test("Gültige Passwörter werden akzeptiert")
    func testValidPasswords() {
        #expect(sut.login(password: "123456") == true)
        #expect(sut.login(password: "Abc12345#") == true)
        #expect(sut.login(password: "testmann") == true)
    }

    /// Verifies that passwords not in the demo list are rejected by `login(password:)`.
    @Test("Ungültige Passwörter werden abgelehnt")
    func testInvalidPasswords() {
        #expect(sut.login(password: "wrongpassword") == false)
        #expect(sut.login(password: "") == false)
        #expect(sut.login(password: " ") == false)
        #expect(sut.login(password: "123456 ") == false)
        #expect(sut.login(password: "TESTMANN") == false)
        #expect(sut.login(password: "abc12345#") == false)
    }

    /// Verifies that `validatePassword("")` returns `.emptyPassword`.
    @Test("Leeres Passwort erzeugt emptyPassword-Fehler")
    func testEmptyPasswordError() {
        let error = sut.validatePassword("")
        #expect(error == .emptyPassword)
    }

    /// Verifies that `validatePassword(_:)` returns `.invalidCredentials` for an unrecognised password.
    @Test("Falsches Passwort erzeugt invalidCredentials-Fehler")
    func testInvalidPasswordError() {
        let error = sut.validatePassword("wrongpassword")
        #expect(error == .invalidCredentials)
    }

    /// Verifies that `validatePassword(_:)` returns `nil` for each of the valid demo passwords.
    @Test("Gültige Passwörter erzeugen keinen Fehler")
    func testValidPasswordNoError() {
        #expect(sut.validatePassword("123456") == nil)
        #expect(sut.validatePassword("Abc12345#") == nil)
        #expect(sut.validatePassword("testmann") == nil)
    }
}

// MARK: - LoginViewModel Tests

/// Unit tests for `LoginViewModel`, verifying button enable state, initial state, and error clearing.
@Suite("LoginViewModel Tests")
struct LoginViewModelTests {

    /// Verifies that the login button is disabled when the password field is empty.
    @Test("Login ist initial deaktiviert bei leerem Passwort")
    func testLoginButtonDisabledWhenEmpty() {
        let vm = LoginViewModel()
        #expect(vm.isLoginButtonEnabled == false)
    }

    /// Verifies that the login button becomes enabled as soon as the password field contains text.
    @Test("Login-Button ist aktiv bei befülltem Passwort")
    func testLoginButtonEnabledWithPassword() {
        let vm = LoginViewModel()
        vm.password = "test"
        #expect(vm.isLoginButtonEnabled == true)
    }

    /// Verifies that a freshly created `LoginViewModel` has no error, no loading state, and no success.
    @Test("LoginViewModel hat initial keinen Fehler")
    func testInitialState() {
        let vm = LoginViewModel()
        #expect(vm.errorMessage == nil)
        #expect(vm.loginSucceeded == false)
        #expect(vm.isLoading == false)
    }

    /// Verifies that calling `clearError()` removes any existing error message.
    @Test("clearError entfernt die Fehlermeldung")
    func testClearError() {
        let vm = LoginViewModel()
        vm.password = "wrong"
        vm.clearError()
        #expect(vm.errorMessage == nil)
    }
}

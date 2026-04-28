import Testing
@testable import BKKAtomium

@Suite("LoginViewModel Async Tests")
@MainActor
struct LoginViewModelAsyncTests {

    @Test("login() mit leerem Passwort setzt errorMessage ohne Verzögerung")
    func testLoginEmptyPasswordSetsError() async {
        let vm = LoginViewModel()
        await vm.login()
        #expect(vm.errorMessage != nil)
        #expect(vm.loginSucceeded == false)
        #expect(vm.isLoading == false)
    }

    @Test("login() mit gültigem Passwort setzt loginSucceeded auf true")
    func testLoginValidPasswordSucceeds() async {
        let vm = LoginViewModel()
        vm.password = "123456"
        await vm.login()
        #expect(vm.loginSucceeded == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("login() mit zweitem gültigem Passwort erfolgreich")
    func testLoginSecondValidPassword() async {
        let vm = LoginViewModel()
        vm.password = "Abc12345#"
        await vm.login()
        #expect(vm.loginSucceeded == true)
    }

    @Test("login() mit drittem gültigem Passwort erfolgreich")
    func testLoginThirdValidPassword() async {
        let vm = LoginViewModel()
        vm.password = "testmann"
        await vm.login()
        #expect(vm.loginSucceeded == true)
    }

    @Test("login() mit falschem Passwort setzt errorMessage und leert Passwortfeld")
    func testLoginInvalidPasswordClearsPassword() async {
        let vm = LoginViewModel()
        vm.password = "wrongpassword"
        await vm.login()
        #expect(vm.errorMessage != nil)
        #expect(vm.loginSucceeded == false)
        #expect(vm.password == "")
        #expect(vm.isLoading == false)
    }

    @Test("isLoginButtonEnabled ist false während isLoading true")
    func testLoginButtonDisabledWhileLoading() {
        let vm = LoginViewModel()
        vm.password = "123456"
        vm.isLoading = true
        #expect(vm.isLoginButtonEnabled == false)
    }

    @Test("Passwort mit nur Leerzeichen führt zu Fehler nach Login")
    func testLoginWhitespacePasswordFails() async {
        let vm = LoginViewModel()
        vm.password = "   "
        await vm.login()
        // "   " is not empty, so login() proceeds - AuthService rejects it
        #expect(vm.loginSucceeded == false)
    }
}

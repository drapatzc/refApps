import Foundation
import Testing
@testable import BKKAtomium

@Suite("AuthError Tests")
struct AuthErrorTests {

    @Test("emptyPassword hat eine nicht-nil errorDescription")
    func testEmptyPasswordDescription() {
        #expect(AuthError.emptyPassword.errorDescription != nil)
    }

    @Test("invalidCredentials hat eine nicht-nil errorDescription")
    func testInvalidCredentialsDescription() {
        #expect(AuthError.invalidCredentials.errorDescription != nil)
    }

    @Test("emptyPassword und invalidCredentials haben verschiedene Beschreibungen")
    func testDescriptionsAreDifferent() {
        let empty = AuthError.emptyPassword.errorDescription
        let invalid = AuthError.invalidCredentials.errorDescription
        #expect(empty != invalid)
    }

    @Test("emptyPassword errorDescription ist nicht leer")
    func testEmptyPasswordDescriptionNotEmpty() {
        let desc = AuthError.emptyPassword.errorDescription ?? ""
        #expect(!desc.isEmpty)
    }

    @Test("invalidCredentials errorDescription ist nicht leer")
    func testInvalidCredentialsDescriptionNotEmpty() {
        let desc = AuthError.invalidCredentials.errorDescription ?? ""
        #expect(!desc.isEmpty)
    }

    @Test("AuthError ist ein Error")
    func testAuthErrorConformsToError() {
        let error: any Error = AuthError.emptyPassword
        #expect(error is AuthError)
    }

    @Test("AuthError ist ein LocalizedError")
    func testAuthErrorConformsToLocalizedError() {
        let error: any LocalizedError = AuthError.invalidCredentials
        #expect(error.errorDescription != nil)
    }

    @Test("AuthService.shared gibt emptyPassword für leeres Passwort zurück")
    func testValidateEmptyPasswordReturnsEmptyPasswordError() {
        let result = AuthService.shared.validatePassword("")
        #expect(result == .emptyPassword)
    }

    @Test("AuthService.shared gibt invalidCredentials für falsches Passwort zurück")
    func testValidateWrongPasswordReturnsInvalidCredentials() {
        let result = AuthService.shared.validatePassword("nichtvorhandenes_passwort_xyz")
        #expect(result == .invalidCredentials)
    }

    @Test("AuthService.shared gibt nil für gültige Passwörter zurück")
    func testValidateCorrectPasswordsReturnNil() {
        #expect(AuthService.shared.validatePassword("123456") == nil)
        #expect(AuthService.shared.validatePassword("Abc12345#") == nil)
        #expect(AuthService.shared.validatePassword("testmann") == nil)
    }
}

import Foundation
@testable import BKKAtomium

// MARK: - MockAuthService

/// Testdouble für `AuthServiceProtocol`.
///
/// Ermöglicht das vollständige Testen von ViewModels, die sich auf
/// Authentifizierung verlassen, ohne echte Passwörter zu benötigen.
///
/// **Verwendung:**
/// ```swift
/// let mock = MockAuthService()
/// mock.loginResult = false
/// let viewModel = LoginViewModel(authService: mock)
/// ```
final class MockAuthService: AuthServiceProtocol {

    /// Steuert, was `login(password:)` zurückgibt. Standard: `true`.
    var loginResult: Bool = true

    /// Steuert, was `validatePassword(_:)` zurückgibt. Standard: `nil` (kein Fehler).
    var validateResult: AuthError? = nil

    /// Steuert, was `canUseBiometrics()` zurückgibt. Standard: `false`.
    var biometricsAvailable: Bool = false

    /// Steuert, was `authenticateWithBiometrics()` zurückgibt. Standard: `false`.
    var biometricsResult: Bool = false

    // MARK: - Aufruf-Zähler (für Assertions in Tests)

    /// Anzahl der `login(password:)`-Aufrufe.
    var loginCallCount: Int = 0

    /// Letztes übergebenes Passwort in `login(password:)`.
    var lastLoginPassword: String?

    // MARK: - Protokoll-Implementierung

    func login(password: String) -> Bool {
        loginCallCount += 1
        lastLoginPassword = password
        return loginResult
    }

    func validatePassword(_ password: String) -> AuthError? {
        validateResult
    }

    func canUseBiometrics() -> Bool {
        biometricsAvailable
    }

    func authenticateWithBiometrics() async -> Bool {
        biometricsResult
    }
}

// MARK: - MockThemeRepository

/// Testdouble für `ThemeRepositoryProtocol`.
///
/// Lädt Themes ohne Bundle-Zugriff, was Tests unabhängig von Ressourcendateien macht.
final class MockThemeRepository: ThemeRepositoryProtocol {

    /// Das zurückzugebende Theme. Standard: `AppThemeModel.default`.
    var stubbedTheme: AppThemeModel = .default

    /// Wirft diesen Fehler wenn gesetzt, statt `stubbedTheme` zurückzugeben.
    var thrownError: AppError? = nil

    /// Alle verfügbaren Theme-Namen. Standard: die drei Standard-Themes.
    var stubbedNames: [String] = ["default", "ocean", "forest"]

    // MARK: - Aufruf-Zähler

    var loadThemeCallCount: Int = 0
    var lastLoadedThemeName: String?

    // MARK: - Protokoll-Implementierung

    func loadTheme(named name: String) async throws -> AppThemeModel {
        loadThemeCallCount += 1
        lastLoadedThemeName = name
        if let error = thrownError { throw error }
        return stubbedTheme
    }

    func availableThemeNames() -> [String] {
        stubbedNames
    }
}

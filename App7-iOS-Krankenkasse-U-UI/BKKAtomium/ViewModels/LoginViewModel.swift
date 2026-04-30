import SwiftUI
import Observation

/// Observable ViewModel für den Login-Screen.
///
/// `LoginViewModel` koordiniert Eingabevalidierung, den asynchronen Login-Ablauf
/// und den UI-Zustand (Lade-Indikator, Fehleranzeige). Es delegiert die eigentliche
/// Passwortprüfung an `AuthServiceProtocol` und ist daher vollständig testbar.
///
/// **Abhängigkeiten:** `AuthServiceProtocol` — via Dependency Injection initialisiert.
///
/// **Testbarkeit:** Mit `MockAuthService` ohne echte Credentials testbar.
///
/// **Zustandsmodell:**
/// - `state == .idle`: Initiale Anzeige
/// - `state == .loading`: Login-Anfrage läuft
/// - `state == .loaded(true)`: Login erfolgreich
/// - `state == .failed(...)`: Login fehlgeschlagen
@Observable
final class LoginViewModel {

    // MARK: - UI-Eigenschaften

    /// Das vom Nutzer eingegebene Klartext-Passwort.
    var password: String = ""

    // MARK: - Zustandsmodell

    /// Der aktuelle Zustand der Login-Operation.
    var state: ViewState<Bool> = .idle

    // MARK: - Abgeleitete Eigenschaften (Rückwärtskompatibilität mit bestehenden Tests)

    /// `true` während eine Login-Anfrage läuft.
    var isLoading: Bool { state.isLoading }

    /// Die anzuzeigende Fehlermeldung, oder `nil` wenn kein Fehler vorliegt.
    var errorMessage: String? { state.error?.errorDescription }

    /// `true` nach einem erfolgreichen Login.
    var loginSucceeded: Bool {
        if case .loaded(let success) = state { return success }
        return false
    }

    // MARK: - Abgeleitete Eigenschaften

    /// `true` wenn der Login-Button aktiv sein soll: Passwort nicht leer und kein Ladevorgang aktiv.
    var isLoginButtonEnabled: Bool {
        !password.isEmpty && !isLoading
    }

    // MARK: - Private Eigenschaften

    /// Der Authentifizierungsdienst — austauschbar über DI.
    private let authService: AuthServiceProtocol

    // MARK: - Initialisierung

    /// Erstellt ein ViewModel mit dem gegebenen Authentifizierungsdienst.
    ///
    /// - Parameter authService: Der Dienst für die Passwortprüfung;
    ///   Standard ist `AuthService.shared`.
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    // MARK: - Öffentliche Methoden

    /// Startet den Login-Vorgang mit dem aktuellen `password`.
    ///
    /// Setzt `state` auf `.loading`, wartet 600 ms (realistische UX-Verzögerung),
    /// dann delegiert an `authService.login(password:)`.
    /// - Bei Fehler: `state = .failed(...)`, Passwort wird mit Spring-Animation geleert.
    /// - Bei Erfolg: `state = .loaded(true)`.
    @MainActor
    func login() async {
        guard !password.isEmpty else {
            state = .failed(.auth(.emptyPassword))
            return
        }

        state = .loading

        // Kurze Verzögerung für realistische UX
        try? await Task.sleep(for: .milliseconds(600))

        let success = authService.login(password: password)

        if success {
            state = .loaded(true)
        } else {
            state = .failed(.auth(.invalidCredentials))

            // Passwort nach Fehler mit Animation leeren
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                password = ""
            }
        }
    }

    /// Setzt den Fehlerzustand zurück.
    func clearError() {
        if case .failed = state {
            state = .idle
        }
    }
}

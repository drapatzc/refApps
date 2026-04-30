import SwiftUI
import Observation

/// Verwaltet das aktive Theme der App und stellt es zentral bereit.
///
/// `AppThemeManager` wird beim App-Start initialisiert und über die
/// SwiftUI-Environment in alle Views injiziert. Das aktive Theme wird
/// aus einem `ThemeRepository` asynchron geladen.
///
/// **Persistenz:** Die Theme-Auswahl wird in `UserDefaults` gespeichert und
/// beim nächsten App-Start wiederhergestellt.
///
/// **Fallback:** Solange kein Theme geladen ist, wird `AppThemeModel.default`
/// verwendet — visuell identisch mit dem hardcodierten `AppTheme`-Enum.
///
/// **Abhängigkeiten:** `ThemeRepositoryProtocol` — austauschbar für Tests.
///
/// **Testbarkeit:** Über `init(repository:)` können Mock-Repositories injiziert werden.
@Observable
final class AppThemeManager {

    // MARK: - UserDefaults-Schlüssel

    /// Schlüssel für die gespeicherte Theme-Auswahl in `UserDefaults`.
    static let selectedThemeKey = "app.theme.selected"

    // MARK: - Öffentliche Eigenschaften

    /// Das aktuell aktive Theme. Wird von Views gelesen.
    private(set) var activeTheme: AppThemeModel = .default

    /// Alle verfügbaren Theme-Namen.
    private(set) var availableThemeNames: [String] = []

    // MARK: - Private Eigenschaften

    private let repository: ThemeRepositoryProtocol

    // MARK: - Initialisierung

    /// Erstellt einen `AppThemeManager` mit der gegebenen Repository-Implementierung.
    ///
    /// - Parameter repository: Das Theme-Repository; Standard ist `ThemeRepository()`.
    init(repository: ThemeRepositoryProtocol = ThemeRepository()) {
        self.repository = repository
        self.availableThemeNames = repository.availableThemeNames()
    }

    // MARK: - Öffentliche Methoden

    /// Lädt das zuletzt gespeicherte Theme aus `UserDefaults`.
    ///
    /// Wird beim App-Start via `.task` aufgerufen. Schlägt die Ladung fehl,
    /// bleibt das Fallback-Theme (`AppThemeModel.default`) aktiv.
    func loadSavedTheme() async {
        let savedName = UserDefaults.standard.string(forKey: Self.selectedThemeKey) ?? "default"
        await loadTheme(named: savedName)
    }

    /// Setzt ein neues Theme und speichert die Auswahl in `UserDefaults`.
    ///
    /// - Parameter name: Technischer Name des Themes.
    @MainActor
    func setTheme(named name: String) async {
        UserDefaults.standard.set(name, forKey: Self.selectedThemeKey)
        await loadTheme(named: name)
    }

    // MARK: - Private Hilfsmethoden

    @MainActor
    private func loadTheme(named name: String) async {
        do {
            let theme = try await repository.loadTheme(named: name)
            activeTheme = theme
            AppTheme.current = theme
        } catch {
            // Fallback auf Default-Theme — kein visueller Unterschied
        }
    }
}

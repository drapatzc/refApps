import Foundation

// MARK: - ThemeRepositoryProtocol

/// Abstrahiert das asynchrone Laden von Theme-Konfigurationsdateien.
///
/// **Verantwortung:** Definiert die Schnittstelle zum Laden und Auflisten von Themes.
/// Ermöglicht den Austausch durch Mock-Implementierungen in Unit-Tests.
protocol ThemeRepositoryProtocol {

    /// Lädt ein Theme asynchron anhand seines technischen Namens.
    ///
    /// - Parameter name: Technischer Name (z. B. "default", "ocean", "forest").
    /// - Returns: Das geladene `AppThemeModel`.
    /// - Throws: `AppError.themeLoading` wenn die Datei nicht gefunden oder nicht
    ///   dekodiert werden kann.
    func loadTheme(named name: String) async throws -> AppThemeModel

    /// Gibt die Namen aller verfügbaren Themes zurück.
    func availableThemeNames() -> [String]
}

// MARK: - ThemeRepository

/// Konkrete Implementierung von `ThemeRepositoryProtocol`.
///
/// Lädt Theme-JSON-Dateien (z. B. `theme-default.json`) aus dem App-Bundle
/// und dekodiert sie in `AppThemeModel`-Instanzen.
///
/// **Dateiformat:** `theme-{name}.json` im Hauptbundle der App.
///
/// **Fehlerbehandlung:** Wirft `AppError.themeLoading` mit einer deutschen
/// Fehlermeldung wenn Datei oder Dekodierung fehlschlägt.
///
/// **Testbarkeit:** Über `ThemeRepositoryProtocol` können Mock-Implementierungen
/// ohne Bundle-Zugriff verwendet werden.
final class ThemeRepository: ThemeRepositoryProtocol {

    /// Alle bekannten Theme-Namen. Entspricht den JSON-Dateinamen ohne Präfix.
    private let knownThemeNames: [String] = ["default", "ocean", "forest"]

    /// Lädt das Theme mit dem angegebenen Namen asynchron aus dem Bundle.
    ///
    /// - Parameter name: Technischer Name des Themes (ohne Präfix "theme-").
    /// - Returns: Das dekodierte `AppThemeModel`.
    /// - Throws: `AppError.themeLoading` wenn Datei fehlt oder JSON ungültig ist.
    func loadTheme(named name: String) async throws -> AppThemeModel {
        let fileName = "theme-\(name)"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw AppError.themeLoading(
                String(localized: "error_theme_file_not_found") + " (\(fileName).json)"
            )
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(AppThemeModel.self, from: data)
        } catch is DecodingError {
            throw AppError.themeLoading(
                String(localized: "error_theme_decoding_failed") + " (\(fileName).json)"
            )
        } catch {
            throw AppError.themeLoading(error.localizedDescription)
        }
    }

    /// Gibt alle verfügbaren Theme-Namen zurück.
    func availableThemeNames() -> [String] {
        knownThemeNames
    }
}

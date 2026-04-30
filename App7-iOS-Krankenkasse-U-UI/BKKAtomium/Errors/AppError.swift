import Foundation

/// Einheitlicher Fehlertyp für die gesamte BKK-Atomium-App.
///
/// `AppError` aggregiert alle Fehlerquellen (Validierung, Authentifizierung,
/// Persistenz, Theme-Laden und unbekannte Fehler) in einen einzigen Typ,
/// den ViewModels in ihren `ViewState.failed`-Zustand übersetzen.
///
/// **Verantwortung:** Zentraler Fehlertyp; alle anderen Fehlerarten werden
/// über `ErrorMapper` hierher konvertiert.
///
/// **Testbarkeit:** Vollständig in Unit-Tests überprüfbar, da kein
/// UI-Code enthalten ist.
enum AppError: Error, LocalizedError, Equatable {

    /// Ein Validierungsfehler bei der Eingabe.
    case validation(ValidationError)

    /// Ein Authentifizierungsfehler (falsches Passwort, biometrisch etc.).
    case auth(AuthError)

    /// Ein Fehler beim Lesen oder Schreiben der SwiftData-Persistenzschicht.
    case persistence(String)

    /// Ein Fehler beim Laden einer Theme-Konfigurationsdatei.
    case themeLoading(String)

    /// Ein unklassifizierter Fehler mit optionaler Ursprungsbeschreibung.
    case unknown(String)

    // MARK: - LocalizedError

    /// Benutzerfreundliche Fehlermeldung in der Sprache der App.
    var errorDescription: String? {
        switch self {
        case .validation(let error):
            return error.errorDescription
        case .auth(let error):
            return error.errorDescription
        case .persistence(let message):
            return String(localized: "error_persistence_prefix") + message
        case .themeLoading(let message):
            return String(localized: "error_theme_loading_prefix") + message
        case .unknown(let message):
            return String(localized: "error_unknown_prefix") + message
        }
    }

    // MARK: - Equatable

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.validation(let l), .validation(let r)):
            return l.errorDescription == r.errorDescription
        case (.auth(let l), .auth(let r)):
            return l.errorDescription == r.errorDescription
        case (.persistence(let l), .persistence(let r)):
            return l == r
        case (.themeLoading(let l), .themeLoading(let r)):
            return l == r
        case (.unknown(let l), .unknown(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - ErrorMapper

/// Konvertiert domänenspezifische Fehlertypen in `AppError`.
///
/// **Verantwortung:** Zentralisiert die Fehlerübersetzung, damit ViewModels
/// nicht direkt gegen domänenspezifische Fehlertypen abhängig sind.
///
/// **Verwendung:** Wird in ViewModels und Services aufgerufen, niemals direkt in Views.
enum ErrorMapper {

    /// Konvertiert einen `ValidationError` in einen `AppError`.
    ///
    /// - Parameter error: Der Validierungsfehler.
    /// - Returns: Ein `AppError.validation`-Wert.
    static func map(_ error: ValidationError) -> AppError {
        .validation(error)
    }

    /// Konvertiert einen `AuthError` in einen `AppError`.
    ///
    /// - Parameter error: Der Authentifizierungsfehler.
    /// - Returns: Ein `AppError.auth`-Wert.
    static func map(_ error: AuthError) -> AppError {
        .auth(error)
    }

    /// Konvertiert einen beliebigen `Error` in einen `AppError`.
    ///
    /// Versucht, bekannte Typen zu erkennen; fällt sonst auf `.unknown` zurück.
    ///
    /// - Parameter error: Der zu konvertierende Fehler.
    /// - Returns: Ein passender `AppError`.
    static func map(_ error: Error) -> AppError {
        switch error {
        case let appError as AppError:
            return appError
        case let validationError as ValidationError:
            return .validation(validationError)
        case let authError as AuthError:
            return .auth(authError)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

import Foundation

/// Repräsentiert den Ladezustand einer asynchronen Operation im ViewModel.
///
/// `ViewState<T>` ersetzt lose `isLoading: Bool` + `errorMessage: String?` + `value: T?`
/// durch einen klar strukturierten Zustandsautomaten. Jeder Zustand schließt die
/// anderen aus, was Race Conditions und inkonsistente UI-Zustände verhindert.
///
/// **Verwendung:**
/// ```swift
/// var state: ViewState<[Address]> = .idle
///
/// func loadAddresses() async {
///     state = .loading
///     do {
///         let items = try repository.fetchAll(for: person)
///         state = .loaded(items)
///     } catch {
///         state = .failed(ErrorMapper.map(error))
///     }
/// }
/// ```
///
/// **Testbarkeit:** Alle Zustandsübergänge sind direkt in Unit-Tests überprüfbar.
enum ViewState<Value> {

    /// Initialer Zustand — noch keine Ladeoperation gestartet.
    case idle

    /// Ladeoperation läuft — UI zeigt einen Spinner.
    case loading

    /// Daten erfolgreich geladen.
    case loaded(Value)

    /// Ladeoperation fehlgeschlagen.
    case failed(AppError)
}

// MARK: - Hilfseigenschaften

extension ViewState {

    /// `true` wenn gerade eine Ladeoperation läuft.
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    /// Der geladene Wert, oder `nil` wenn noch nicht geladen oder ein Fehler aufgetreten ist.
    var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    /// Der aufgetretene Fehler, oder `nil` wenn kein Fehler vorliegt.
    var error: AppError? {
        if case .failed(let error) = self { return error }
        return nil
    }

    /// `true` wenn Daten erfolgreich geladen wurden.
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }

    /// `true` wenn ein Fehler vorliegt.
    var hasFailed: Bool {
        if case .failed = self { return true }
        return false
    }
}

// MARK: - Equatable

extension ViewState: Equatable where Value: Equatable {

    static func == (lhs: ViewState<Value>, rhs: ViewState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lValue), .loaded(let rValue)):
            return lValue == rValue
        case (.failed(let lError), .failed(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}

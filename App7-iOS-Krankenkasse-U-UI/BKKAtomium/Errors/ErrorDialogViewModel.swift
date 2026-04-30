import Foundation
import Observation

/// Steuert die Anzeige des zentralen Fehler-Dialogs.
///
/// `ErrorDialogViewModel` wird in ViewModels oder Services befüllt und via
/// Environment (oder DI) in den relevanten Views präsentiert. Es hält den
/// aktuellen Fehler und steuert ob der Dialog sichtbar ist.
///
/// **Verantwortung:** Brücke zwischen Fehlerquellen (Services, Repositories) und
/// der UI-Darstellung. Nur dieses ViewModel darf den Fehler-Dialog steuern.
///
/// **Testbarkeit:** Vollständig testbar ohne SwiftUI-Dependencies.
@Observable
final class ErrorDialogViewModel {

    // MARK: - Öffentliche Eigenschaften

    /// Der aktuell angezeigte Fehler, oder `nil` wenn kein Fehler vorliegt.
    private(set) var currentError: AppError? = nil

    /// `true` wenn der Fehler-Dialog sichtbar ist.
    var isPresented: Bool = false

    // MARK: - Öffentliche Methoden

    /// Zeigt den Fehler-Dialog mit dem gegebenen Fehler an.
    ///
    /// - Parameter error: Der anzuzeigende Fehler.
    @MainActor
    func present(_ error: AppError) {
        currentError = error
        isPresented = true
    }

    /// Schließt den Fehler-Dialog und löscht den Fehler.
    @MainActor
    func dismiss() {
        isPresented = false
        currentError = nil
    }

    /// Konvertiert einen beliebigen Fehler und zeigt ihn an.
    ///
    /// - Parameter error: Der zu konvertierende und anzuzeigende Fehler.
    @MainActor
    func present(anyError error: Error) {
        present(ErrorMapper.map(error))
    }
}

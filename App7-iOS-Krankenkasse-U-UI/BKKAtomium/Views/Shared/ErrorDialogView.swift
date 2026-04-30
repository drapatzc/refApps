import SwiftUI

/// Zentraler Fehler-Dialog für alle AppError-Typen.
///
/// `ErrorDialogView` wird über einen `ErrorDialogViewModel` gesteuert und zeigt
/// einen benutzerfreundlichen Alert mit dem Fehlertitel und der Fehlerbeschreibung an.
///
/// **Verwendung:**
/// ```swift
/// struct MyView: View {
///     @State private var errorDialog = ErrorDialogViewModel()
///
///     var body: some View {
///         ContentView()
///             .errorDialog(viewModel: errorDialog)
///     }
/// }
/// ```
///
/// **Verantwortung:** Reine Darstellungsschicht — keine Geschäftslogik enthalten.
struct ErrorDialogModifier: ViewModifier {

    /// Das ViewModel, das den Dialog steuert.
    @Bindable var viewModel: ErrorDialogViewModel

    func body(content: Content) -> some View {
        content
            .alert(
                errorTitle(for: viewModel.currentError),
                isPresented: $viewModel.isPresented
            ) {
                Button(String(localized: "error_dialog_dismiss_button"), role: .cancel) {
                    viewModel.dismiss()
                }
            } message: {
                if let error = viewModel.currentError {
                    Text(error.errorDescription ?? String(localized: "error_unknown_prefix"))
                }
            }
    }

    /// Gibt den Alert-Titel basierend auf dem Fehlertyp zurück.
    private func errorTitle(for error: AppError?) -> String {
        guard let error else { return String(localized: "error_dialog_title_generic") }

        switch error {
        case .validation:
            return String(localized: "error_dialog_title_validation")
        case .auth:
            return String(localized: "error_dialog_title_auth")
        case .persistence:
            return String(localized: "error_dialog_title_persistence")
        case .themeLoading:
            return String(localized: "error_dialog_title_theme")
        case .unknown:
            return String(localized: "error_dialog_title_generic")
        }
    }
}

// MARK: - View Extension

extension View {

    /// Hängt einen zentralen Fehler-Dialog an diese View.
    ///
    /// - Parameter viewModel: Das `ErrorDialogViewModel` das den Dialog steuert.
    /// - Returns: Die View mit angehängtem Fehler-Alert.
    func errorDialog(viewModel: ErrorDialogViewModel) -> some View {
        modifier(ErrorDialogModifier(viewModel: viewModel))
    }
}

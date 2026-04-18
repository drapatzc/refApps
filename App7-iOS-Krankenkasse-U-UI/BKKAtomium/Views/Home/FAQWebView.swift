import SwiftUI
import SafariServices

/// A SwiftUI wrapper around `SFSafariViewController` for displaying a web-based FAQ page.
///
/// Reader mode is intentionally disabled; the primary tint is set to the app's primary color.
struct FAQWebView: UIViewControllerRepresentable {

    /// The URL to load in Safari.
    let url: URL

    /// Creates and configures a new `SFSafariViewController` for the given URL.
    ///
    /// - Parameter context: The representable context provided by SwiftUI.
    /// - Returns: A configured `SFSafariViewController`.
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let controller = SFSafariViewController(url: url, configuration: config)
        controller.preferredControlTintColor = UIColor(AppTheme.primary)
        controller.dismissButtonStyle = .close
        return controller
    }

    /// No-op update since `SFSafariViewController` manages its own state.
    ///
    /// - Parameters:
    ///   - uiViewController: The existing safari view controller.
    ///   - context: The representable context provided by SwiftUI.
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

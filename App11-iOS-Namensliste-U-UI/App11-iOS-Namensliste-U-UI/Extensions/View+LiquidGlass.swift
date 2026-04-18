import SwiftUI

// MARK: - Liquid Glass Unterstützung (iOS 26+)
//
// iOS 26 führt das "Liquid Glass"-Designsystem ein.
// Die folgenden Modifier aktivieren den Glaseffekt für
// kompatible iOS-Versionen und behalten das Standardverhalten
// auf älteren Systemen bei.

extension View {

    /// Wendet den Liquid Glass Effekt auf einen View an (iOS 26+).
    @ViewBuilder
    func liquidGlass() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular)
        } else {
            self
        }
    }

    /// Wendet den Liquid Glass Effekt mit einer Formvorgabe an (iOS 26+).
    @ViewBuilder
    func liquidGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self
        }
    }

    /// Wendet einen Liquid Glass Listenstil an (iOS 26+).
    @ViewBuilder
    func liquidGlassListBackground() -> some View {
        if #available(iOS 26, *) {
            self.scrollContentBackground(.hidden)
                .background(.clear)
        } else {
            self
        }
    }

    /// Wendet einen Liquid Glass Sheet-Hintergrund an (iOS 26+).
    @ViewBuilder
    func liquidGlassPresentation() -> some View {
        if #available(iOS 26, *) {
            self.presentationBackground(.regularMaterial)
        } else {
            self
        }
    }
}

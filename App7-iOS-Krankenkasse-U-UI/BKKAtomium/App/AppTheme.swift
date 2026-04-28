import SwiftUI

/// Central design token container for the BKK Atomium app.
enum AppTheme {
    // MARK: - Primärfarben

    static let primary = Color(red: 0.11, green: 0.29, blue: 0.50)
    static let accent  = Color(red: 0.10, green: 0.38, blue: 0.24)

    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.22, blue: 0.42),
            Color(red: 0.10, green: 0.38, blue: 0.28)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let headerGradient = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.18, blue: 0.36),
            Color(red: 0.09, green: 0.30, blue: 0.22)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground:    Color = Color(.systemBackground)
    static let sectionBackground: Color = Color(.secondarySystemGroupedBackground)
    static let groupedBackground: Color = Color(.systemGroupedBackground)

    // MARK: - Abstände

    static let spacingXS:  CGFloat = 4
    static let spacingS:   CGFloat = 8
    static let spacingM:   CGFloat = 16
    static let spacingL:   CGFloat = 24
    static let spacingXL:  CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: - Eckenradien

    static let cornerRadiusS:  CGFloat = 8
    static let cornerRadiusM:  CGFloat = 12
    static let cornerRadiusL:  CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20

    // MARK: - Animationen

    /// Bouncy spring (0.4 s) — für Karten-Interaktionen und Icon-Erscheinen.
    static let animationBouncy = Animation.bouncy(duration: 0.4)

    /// Smooth spring (0.4 s) — für UI-Übergänge und Sheet-Präsentationen.
    static let animationSmooth = Animation.smooth(duration: 0.4)

    /// Snappy spring (0.3 s) — für schnelle Bestätigungen und Zustandswechsel.
    static let animationSnappy = Animation.snappy(duration: 0.3)
}

// MARK: - View Modifier

extension View {

    func appCardStyle(colorScheme: ColorScheme = .light) -> some View {
        self
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.25)
                    : Color.black.opacity(0.07),
                radius: 12, x: 0, y: 4
            )
    }

    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingM)
            .background(AppTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }

    func destructiveButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingM)
            .background(Color.red.gradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }

    /// Markiert diese View als Startpunkt einer iOS 18 Zoom-Navigation.
    @ViewBuilder
    func zoomTransitionSource<ID: Hashable>(id: ID, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    /// Wendet eine iOS 18 Zoom-Transition auf die Ziel-View an.
    @ViewBuilder
    func zoomTransitionDestination<ID: Hashable>(id: ID, in namespace: Namespace.ID) -> some View {
        #if canImport(UIKit)
        if #available(iOS 18, *) {
            self.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
        #else
        self
        #endif
    }
}

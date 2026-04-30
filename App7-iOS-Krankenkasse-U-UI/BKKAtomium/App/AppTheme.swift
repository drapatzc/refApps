import SwiftUI

/// Central design token container for the BKK Atomium app.
///
/// Die Farbwerte, Abstände und Eckenradien sind dynamisch: Sie werden aus
/// `AppTheme.current` berechnet, das von `AppThemeManager` beim Themenwechsel
/// aktualisiert wird. Alle Views lesen weiterhin `AppTheme.*` — kein View-Code
/// muss geändert werden. `BKKAtomiumApp` erzwingt per `.id(activeTheme.name)`
/// einen vollständigen View-Neuaufbau, sobald sich `current` ändert.
enum AppTheme {

    // MARK: - Aktives Theme (wird von AppThemeManager gesetzt)

    /// Referenz auf das aktuell aktive Theme. Thread-sicher für Lese-/Schreibzugriff
    /// aus dem Main-Actor-Kontext von AppThemeManager.
    // swiftlint:disable:next nonisolated_unsafe
    nonisolated(unsafe) static var current: AppThemeModel = .default

    // MARK: - Primärfarben

    static var primary: Color { current.primaryColor }
    static var accent:  Color { current.accentColor }

    static var primaryGradient: LinearGradient { current.primaryGradient }
    static var headerGradient:  LinearGradient { current.headerGradient }

    static let cardBackground:    Color = Color(.systemBackground)
    static let sectionBackground: Color = Color(.secondarySystemGroupedBackground)
    static let groupedBackground: Color = Color(.systemGroupedBackground)

    // MARK: - Abstände

    static var spacingXS:  CGFloat { current.spacingXS }
    static var spacingS:   CGFloat { current.spacingS }
    static var spacingM:   CGFloat { current.spacingM }
    static var spacingL:   CGFloat { current.spacingL }
    static var spacingXL:  CGFloat { current.spacingXL }
    static var spacingXXL: CGFloat { current.spacingXXL }

    // MARK: - Eckenradien

    static var cornerRadiusS:  CGFloat { current.cornerRadiusS }
    static var cornerRadiusM:  CGFloat { current.cornerRadiusM }
    static var cornerRadiusL:  CGFloat { current.cornerRadiusL }
    static var cornerRadiusXL: CGFloat { current.cornerRadiusXL }

    // MARK: - Animationen (theme-unabhängig)

    /// Bouncy spring (0.4 s) — für Karten-Interaktionen und Icon-Erscheinen.
    static let animationBouncy = Animation.bouncy(duration: 0.4)

    /// Smooth spring (0.4 s) — für UI-Übergänge und Sheet-Präsentationen.
    static let animationSmooth = Animation.smooth(duration: 0.4)

    /// Snappy spring (0.3 s) — für schnelle Bestätigungen und Zustandswechsel.
    static let animationSnappy = Animation.snappy(duration: 0.3)
}

// MARK: - PressableButtonStyle

/// Button-Stil mit Scale-Animation beim Tap und haptic Feedback.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, new in new }
    }
}

// MARK: - ShimmerModifier

/// View-Modifer für animierten Shimmer-Effekt beim Laden.
struct ShimmerModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        ZStack {
            content

            if isLoading {
                TimelineView(.animation) { timeline in
                    let now = timeline.date.timeIntervalSince1970
                    let phase = (now.truncatingRemainder(dividingBy: 1.5) / 1.5) * 2 - 1

                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0), location: phase - 0.15),
                            .init(color: .white.opacity(0.4), location: phase),
                            .init(color: .white.opacity(0), location: phase + 0.15)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .ignoresSafeArea()
                }
            }
        }
    }
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
            .buttonStyle(PressableButtonStyle())
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

    /// Färbt die View mit dem Primär-Gradient (für Texte).
    func gradientText() -> some View {
        self
            .foregroundStyle(AppTheme.primaryGradient)
    }

    /// Wendet einen animierten Shimmer-Effekt an, wenn `isLoading == true`.
    func shimmer(isLoading: Bool = false) -> some View {
        modifier(ShimmerModifier(isLoading: isLoading))
    }
}

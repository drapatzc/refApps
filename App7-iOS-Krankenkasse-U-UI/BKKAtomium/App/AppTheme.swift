import SwiftUI

/// Central design token container for the BKK Atomium app.
///
/// `AppTheme` provides static constants for colors, gradients, spacing, and
/// corner radii used throughout the app. All values are code-defined — no
/// `Assets.xcassets` entries are required.
enum AppTheme {
    // MARK: - Primärfarben (kein Assets.xcassets nötig)

    /// The app's primary dark-blue brand color.
    static let primary = Color(red: 0.11, green: 0.29, blue: 0.50)      // Dunkelblau

    /// The app's accent dark-green color, used for secondary interactive elements.
    static let accent  = Color(red: 0.10, green: 0.38, blue: 0.24)      // Dunkelgrün

    /// A diagonal gradient from dark blue to dark green, used for primary buttons and highlights.
    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.22, blue: 0.42),
            Color(red: 0.10, green: 0.38, blue: 0.28)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// A diagonal gradient used in section and card headers.
    static let headerGradient = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.18, blue: 0.36),
            Color(red: 0.09, green: 0.30, blue: 0.22)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// The background color for individual card surfaces (adapts to light/dark mode).
    static let cardBackground    = Color(.systemBackground)

    /// The background color for secondary grouped sections.
    static let sectionBackground = Color(.secondarySystemGroupedBackground)

    /// The background color for grouped list screens.
    static let groupedBackground = Color(.systemGroupedBackground)

    // MARK: - Abstände

    /// Extra-small spacing constant (4 pt).
    static let spacingXS:  CGFloat = 4

    /// Small spacing constant (8 pt).
    static let spacingS:   CGFloat = 8

    /// Medium spacing constant (16 pt).
    static let spacingM:   CGFloat = 16

    /// Large spacing constant (24 pt).
    static let spacingL:   CGFloat = 24

    /// Extra-large spacing constant (32 pt).
    static let spacingXL:  CGFloat = 32

    /// Double-extra-large spacing constant (48 pt).
    static let spacingXXL: CGFloat = 48

    // MARK: - Eckenradien

    /// Small corner radius (8 pt), used for text fields and minor elements.
    static let cornerRadiusS:  CGFloat = 8

    /// Medium corner radius (12 pt), used for buttons and banners.
    static let cornerRadiusM:  CGFloat = 12

    /// Large corner radius (16 pt), used for cards.
    static let cornerRadiusL:  CGFloat = 16

    /// Extra-large corner radius (20 pt), used for prominent sheets and hero cards.
    static let cornerRadiusXL: CGFloat = 20
}

// MARK: - View Modifier

extension View {

    /// Applies the standard card styling: white/system background, rounded corners, and a subtle drop shadow.
    ///
    /// - Parameter colorScheme: The current color scheme, used to select the appropriate shadow opacity.
    /// - Returns: The view styled as an app card.
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

    /// Applies the primary call-to-action button style: bold white text, full-width, gradient background.
    ///
    /// - Returns: The view styled as a primary button.
    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingM)
            .background(AppTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }

    /// Applies the destructive button style: bold white text, full-width, red background.
    ///
    /// - Returns: The view styled as a destructive button.
    func destructiveButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingM)
            .background(Color.red.gradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }
}

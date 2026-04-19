import SwiftUI

/// BKK Orano design system — warm terracotta orange palette.
///
/// All colors are defined in code; no Assets.xcassets color entries required.
/// Values follow an Apple-inspired hierarchy: calm backgrounds, expressive
/// accent surfaces, and a single trusted primary for action and identity.
enum AppTheme {

    // MARK: - Brand palette

    /// Deep burnt orange — primary brand color.
    static let primary = Color(red: 0.84, green: 0.33, blue: 0.11)   // #D65519

    /// Rich cinnamon — darker companion used in gradients and shadows.
    static let primaryDeep = Color(red: 0.66, green: 0.23, blue: 0.06) // #A93B10

    /// Warm amber — soft accent for highlights and secondary actions.
    static let accent = Color(red: 0.95, green: 0.60, blue: 0.28)   // #F29948

    /// Soft sunset peach — decorative background tint.
    static let peach = Color(red: 0.98, green: 0.87, blue: 0.74)    // #FBDEBD

    /// Deep warm brown — foreground color on light surfaces.
    static let ink = Color(red: 0.22, green: 0.14, blue: 0.09)      // #382418

    // MARK: - Semantic surfaces

    /// Surface for cards and sheets.
    static let cardBackground = Color(.systemBackground)

    /// Subtle grouped background (warm-tinted system color).
    static let surface = Color(.secondarySystemGroupedBackground)

    /// Canvas background for main screens.
    static let canvas = Color(.systemGroupedBackground)

    /// Success tint.
    static let success = Color(red: 0.15, green: 0.55, blue: 0.38)

    /// Destructive / error tint.
    static let danger = Color(red: 0.83, green: 0.22, blue: 0.20)

    // MARK: - Gradients

    /// Signature brand gradient (deep → bright orange) — used on hero areas.
    static let heroGradient = LinearGradient(
        colors: [primaryDeep, primary, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Compact action gradient for buttons.
    static let actionGradient = LinearGradient(
        colors: [primary, primaryDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Soft surface gradient for banners and cards.
    static let softGradient = LinearGradient(
        colors: [peach.opacity(0.6), peach.opacity(0.25)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Glow overlay used on decorative shapes.
    static let glowGradient = RadialGradient(
        colors: [accent.opacity(0.55), .clear],
        center: .center,
        startRadius: 0,
        endRadius: 220
    )

    // MARK: - Spacing

    static let spaceXS:  CGFloat = 4
    static let spaceS:   CGFloat = 8
    static let spaceM:   CGFloat = 16
    static let spaceL:   CGFloat = 24
    static let spaceXL:  CGFloat = 32
    static let spaceXXL: CGFloat = 48

    // MARK: - Radii

    static let radiusS:  CGFloat = 10
    static let radiusM:  CGFloat = 16
    static let radiusL:  CGFloat = 22
    static let radiusXL: CGFloat = 28

    // MARK: - Typography

    /// Large display title (hero sections).
    static let displayFont:  Font = .system(.largeTitle, design: .serif, weight: .semibold)
    /// Section headline (card titles).
    static let headlineFont: Font = .system(.title2, design: .default, weight: .semibold)
    /// Body / descriptive copy.
    static let bodyFont:     Font = .system(.body, design: .default)
    /// Numeric / data readout.
    static let monoFont:     Font = .system(.body, design: .monospaced).weight(.medium)
}

// MARK: - View modifiers

extension View {

    /// Applies the standard Orano card treatment: warm background + soft shadow.
    func oranoCard(colorScheme: ColorScheme = .light) -> some View {
        self
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.35)
                    : AppTheme.primaryDeep.opacity(0.08),
                radius: 14, x: 0, y: 6
            )
    }

    /// Primary call-to-action button styling.
    func oranoPrimaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .background(AppTheme.actionGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .shadow(color: AppTheme.primary.opacity(0.35), radius: 10, x: 0, y: 4)
    }

    /// Tonal secondary button with peach background.
    func oranoSecondaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .background(AppTheme.peach.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
    }

    /// Destructive button.
    func oranoDestructiveButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .background(AppTheme.danger.gradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
    }
}

import SwiftUI

/// BKK Orano 2.0 design system — blue & orange, Google-Material influenced.
///
/// Evolution note (v1 → v2): the warm terracotta palette of v1 gives way to a
/// calmer, trust-driven blue anchor with an energetic orange accent. The type
/// system switches from serif display to a rounded sans-serif so the product
/// feels more digital-native, closer to Google Material 3 than to the
/// editorial Apple Health feel of v1.
enum AppTheme {

    // MARK: - Brand palette

    /// Trusted Google-style blue — the primary brand anchor.
    static let primary = Color(red: 0.10, green: 0.46, blue: 0.91)     // #1A75E8

    /// Deeper navy — used on gradients, pressed states.
    static let primaryDeep = Color(red: 0.04, green: 0.32, blue: 0.78) // #0A52C7

    /// Very light sky tint — soft surface background.
    static let primarySoft = Color(red: 0.87, green: 0.93, blue: 1.00) // #DFEDFF

    /// Energetic orange — the secondary brand color, used sparingly
    /// to signal actions and highlights.
    static let accent = Color(red: 0.96, green: 0.62, blue: 0.04)      // #F59E0B

    /// Deeper amber for accent gradient endpoints.
    static let accentDeep = Color(red: 0.85, green: 0.47, blue: 0.02)  // #D97706

    /// Soft peach for accent backgrounds.
    static let accentSoft = Color(red: 1.00, green: 0.94, blue: 0.84)  // #FFF0D6

    /// Cool ink — foreground text color on light surfaces (not warm brown as in v1).
    static let ink = Color(red: 0.10, green: 0.13, blue: 0.18)         // #1A202C

    // MARK: - Semantic surfaces

    /// Canvas background for main screens.
    static let canvas = Color(.systemGroupedBackground)

    /// Surface for cards (paper).
    static let cardBackground = Color(.systemBackground)

    /// Subtle inner surface for nested groups.
    static let surface = Color(.secondarySystemGroupedBackground)

    /// Success / positive tint — calm green.
    static let success = Color(red: 0.13, green: 0.58, blue: 0.35)     // #21945A

    /// Warning tint.
    static let warning = Color(red: 0.96, green: 0.62, blue: 0.04)

    /// Destructive / error tint.
    static let danger = Color(red: 0.80, green: 0.24, blue: 0.24)      // #CC3D3D

    // MARK: - Gradients

    /// Brand gradient (deep navy → primary → accent orange) — used on hero bands.
    /// This blue-to-orange horizon line is the single most distinctive
    /// signature of v2; it ties every hero surface together.
    static let heroGradient = LinearGradient(
        colors: [primaryDeep, primary, accent.opacity(0.80)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Compact solid-blue gradient for primary action buttons.
    static let actionGradient = LinearGradient(
        colors: [primary, primaryDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Warm orange gradient for energetic accent buttons.
    static let warmGradient = LinearGradient(
        colors: [accent, accentDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Horizon gradient — deep blue → soft orange — for landscape illustrations.
    static let horizonGradient = LinearGradient(
        colors: [primaryDeep, primary, accent, Color(red: 1.0, green: 0.85, blue: 0.6)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Soft tonal gradient — sky-blue tint on white.
    static let softGradient = LinearGradient(
        colors: [primarySoft.opacity(0.9), Color.white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Glow overlay used on decorative shapes.
    static let glowGradient = RadialGradient(
        colors: [accent.opacity(0.45), .clear],
        center: .center,
        startRadius: 0,
        endRadius: 220
    )

    // MARK: - Spacing (8-pt base grid)

    static let spaceXS:  CGFloat = 4
    static let spaceS:   CGFloat = 8
    static let spaceM:   CGFloat = 16
    static let spaceL:   CGFloat = 24
    static let spaceXL:  CGFloat = 32
    static let spaceXXL: CGFloat = 48

    // MARK: - Radii (tighter than v1 — closer to Material's 12/16 scale)

    static let radiusS:  CGFloat = 10
    static let radiusM:  CGFloat = 14
    static let radiusL:  CGFloat = 18
    static let radiusXL: CGFloat = 24

    // MARK: - Elevation (Material-style shadow tokens)

    struct Elevation {
        let radius: CGFloat
        let y: CGFloat
        let opacity: Double
    }

    static let elevation1 = Elevation(radius: 4,  y: 1, opacity: 0.08)
    static let elevation2 = Elevation(radius: 10, y: 3, opacity: 0.10)
    static let elevation3 = Elevation(radius: 18, y: 6, opacity: 0.14)

    // MARK: - Typography (rounded sans-serif — v1 used serif)

    /// Large display — rounded, bold.
    static let displayFont:   Font = .system(.largeTitle, design: .rounded, weight: .bold)
    /// Section headline.
    static let headlineFont:  Font = .system(.title3, design: .rounded, weight: .semibold)
    /// Title on cards.
    static let cardTitleFont: Font = .system(.headline, design: .rounded, weight: .semibold)
    /// Body / descriptive copy — default design for readability.
    static let bodyFont:      Font = .system(.body, design: .default)
    /// Numeric / data readout.
    static let monoFont:      Font = .system(.body, design: .monospaced).weight(.medium)
}

// MARK: - View modifiers

extension View {

    /// Standard Orano v2 card: soft Material shadow, crisp corners, paper surface.
    func oranoCard() -> some View {
        self
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(
                color: AppTheme.ink.opacity(AppTheme.elevation2.opacity),
                radius: AppTheme.elevation2.radius,
                x: 0,
                y: AppTheme.elevation2.y
            )
    }

    /// Flat (elevation-1) card for compact rows / inline groups.
    func oranoCardFlat() -> some View {
        self
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .shadow(
                color: AppTheme.ink.opacity(AppTheme.elevation1.opacity),
                radius: AppTheme.elevation1.radius,
                x: 0,
                y: AppTheme.elevation1.y
            )
    }

    /// Primary call-to-action: filled blue.
    func oranoPrimaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .background(AppTheme.actionGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .shadow(color: AppTheme.primary.opacity(0.30), radius: 10, x: 0, y: 4)
    }

    /// Warm orange button — energetic "hero" action.
    func oranoAccentButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .background(AppTheme.warmGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .shadow(color: AppTheme.accent.opacity(0.32), radius: 10, x: 0, y: 4)
    }

    /// Tonal ghost button: blue text on soft sky background.
    func oranoSecondaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spaceM)
            .background(AppTheme.primarySoft)
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

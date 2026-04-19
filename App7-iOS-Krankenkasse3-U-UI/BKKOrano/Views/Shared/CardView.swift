import SwiftUI

// MARK: - Section header

/// Section title used above grouped content (rounded sans-serif, blue accent icon).
/// Evolution note: v1 used uppercase tracked caps with an orange glyph. v2
/// drops the tracking, uses standard casing, and treats the optional icon as
/// a subtle blue marker — in line with the Material/Google direction.
struct OranoSectionHeader: View {
    let title: String
    var icon: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: AppTheme.spaceS) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)
            }
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
            Spacer(minLength: 0)
            if let trailing { trailing }
        }
        .padding(.horizontal, AppTheme.spaceL)
    }
}

// MARK: - Generic content card

struct OranoCard<Content: View>: View {
    var padding: CGFloat = AppTheme.spaceM
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .oranoCard()
    }
}

// MARK: - Info row (icon + label + value)

struct OranoInfoRow: View {
    let title: String
    let value: String
    var icon: String? = nil
    var isPrimary: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spaceM) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
            Spacer(minLength: 0)
            if isPrimary {
                OranoPrimaryBadge()
            }
        }
        .padding(.vertical, AppTheme.spaceXS)
    }
}

// MARK: - Primary badge

struct OranoPrimaryBadge: View {
    var body: some View {
        Text(String(localized: "badge_primary"))
            .font(.caption2.weight(.bold))
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(AppTheme.warmGradient)
            .clipShape(Capsule())
    }
}

// MARK: - Error / success banners

struct OranoErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spaceS) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppTheme.danger)
            Text(message)
                .font(.footnote)
                .foregroundStyle(AppTheme.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.danger.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.spaceM)
        .background(AppTheme.danger.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
    }
}

struct OranoSuccessBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: AppTheme.spaceS) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.success)
            Text(message)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppTheme.success)
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.success.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
    }
}

// MARK: - Empty state

struct OranoEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: AppTheme.spaceM) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(AppTheme.primary.opacity(0.7))
                .padding(AppTheme.spaceL)
                .background(AppTheme.primarySoft)
                .clipShape(Circle())
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spaceXL)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Input field

struct OranoTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var secure: Bool = false
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Group {
                if secure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(capitalization)
                }
            }
            .textFieldStyle(.plain)
            .font(.body)
            .padding(.vertical, 12)
            .padding(.horizontal, AppTheme.spaceM)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                    .strokeBorder(AppTheme.primary.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

// MARK: - Chip / pill (Material-style filter chip)

struct OranoChip: View {
    let text: String
    var icon: String? = nil
    var filled: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(text)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(filled ? AnyShapeStyle(AppTheme.primary) : AnyShapeStyle(AppTheme.primarySoft))
        .foregroundStyle(filled ? Color.white : AppTheme.primary)
        .clipShape(Capsule())
    }
}

// MARK: - Placeholder destination

struct OranoPlaceholder: View {
    let icon: String
    let title: String

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spaceL) {
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(AppTheme.primary)
                    .padding(AppTheme.spaceXL)
                    .background(AppTheme.primarySoft)
                    .clipShape(Circle())

                Text(title)
                    .font(.system(.title, design: .rounded, weight: .semibold))

                Text(String(localized: "placeholder_coming_soon"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spaceL)
            }
            .padding(.top, AppTheme.spaceXXL)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hero gradient background

/// Decorative background used on Login — blue→orange horizon with a soft radial glow.
struct OranoHeroBackground: View {
    var body: some View {
        ZStack {
            AppTheme.heroGradient
                .ignoresSafeArea()
            GeometryReader { geo in
                Circle()
                    .fill(AppTheme.glowGradient)
                    .frame(width: geo.size.width * 1.3, height: geo.size.width * 1.3)
                    .offset(x: -geo.size.width * 0.3, y: -geo.size.width * 0.3)
                Circle()
                    .fill(AppTheme.glowGradient)
                    .frame(width: geo.size.width * 1.1, height: geo.size.width * 1.1)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.4)
                    .blendMode(.softLight)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }
}

// MARK: - v2: Discover feed card (big image + title + subtitle)

/// A Google-inspired feed card: hero image on top, copy below — used in the
/// new Home "Entdecken" feed and wherever a visual highlight is warranted.
struct OranoFeedCard: View {
    let imageName: String
    let eyebrow: String
    let title: String
    let subtitle: String
    var tint: Color = AppTheme.primary
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.45)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                    Text(eyebrow)
                        .font(.caption2.weight(.bold))
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(tint.opacity(0.85))
                        .clipShape(Capsule())
                        .padding(AppTheme.spaceM)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding(AppTheme.spaceM)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .oranoCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - v2: Service tile (Material-style)

/// Compact tile used on Service/Health hubs: icon chip on top, title below.
struct OranoServiceTile: View {
    let icon: String
    let title: String
    let subtitle: String
    var tint: Color = AppTheme.primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spaceS) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(tint)
                }
                Spacer(minLength: 6)
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding(AppTheme.spaceM)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .oranoCardFlat()
        }
        .buttonStyle(.plain)
    }
}

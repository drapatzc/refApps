import SwiftUI

// MARK: - Section header

/// Section title used above grouped content (uppercase tracking, orange accent).
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
                .font(.footnote.weight(.semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            if let trailing { trailing }
        }
        .padding(.horizontal, AppTheme.spaceM)
        .padding(.top, AppTheme.spaceS)
    }
}

// MARK: - Generic content card

struct OranoCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var padding: CGFloat = AppTheme.spaceM
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .oranoCard(colorScheme: colorScheme)
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
                    .frame(width: 28, height: 28)
                    .background(AppTheme.peach.opacity(0.5))
                    .clipShape(Circle())
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
            .background(AppTheme.actionGradient)
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
                .foregroundStyle(AppTheme.primary.opacity(0.6))
                .padding(AppTheme.spaceL)
                .background(AppTheme.peach.opacity(0.35))
                .clipShape(Circle())
            Text(title)
                .font(.title3.weight(.semibold))
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

// MARK: - Chip / pill

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
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(filled ? AppTheme.primary : AppTheme.peach.opacity(0.45))
        .foregroundStyle(filled ? .white : AppTheme.primary)
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
                    .background(AppTheme.peach.opacity(0.35))
                    .clipShape(Circle())

                Text(title)
                    .font(.title.weight(.semibold))

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

/// Decorative background used on Login and hero screens — radial glow layered on the brand gradient.
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

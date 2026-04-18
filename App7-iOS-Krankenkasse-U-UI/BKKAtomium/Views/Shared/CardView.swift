import SwiftUI

/// A generic container view that applies the standard card appearance:
/// a system background, rounded corners, and a subtle drop shadow.
struct CardView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    /// The wrapped content to display inside the card.
    let content: Content

    /// Creates a card view with the given content builder.
    ///
    /// - Parameter content: A view builder closure that produces the card's content.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// Renders the content with card styling applied.
    var body: some View {
        content
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Color.black.opacity(0.07),
                radius: 12, x: 0, y: 4
            )
    }
}

/// A horizontal row that displays a label, a value, an optional icon, and an optional primary badge.
struct InfoRowView: View {

    /// The caption label shown above the value.
    let label: String

    /// The main value text.
    let value: String

    /// An optional SF Symbols name displayed to the left of the label and value.
    var icon: String? = nil

    /// When `true`, a `PrimaryBadge` is shown on the trailing edge.
    var isPrimary: Bool = false

    /// Renders the icon, label/value stack, and an optional primary badge.
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingM) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            if isPrimary {
                PrimaryBadge()
            }
        }
        .padding(.vertical, AppTheme.spacingS)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

/// A small capsule badge that marks an item as the primary entry in its collection.
struct PrimaryBadge: View {

    /// Renders a white-on-primary-gradient capsule with the localized "primary" label.
    var body: some View {
        Text(String(localized: "badge_primary"))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(AppTheme.primary.gradient)
            .clipShape(Capsule())
    }
}

/// A section header row with an optional leading icon.
struct SectionHeaderView: View {

    /// The title text for the section header.
    let title: String

    /// An optional SF Symbols name shown to the left of the title.
    var systemImage: String? = nil

    /// Renders the icon and uppercase title with the standard section header appearance.
    var body: some View {
        HStack(spacing: AppTheme.spacingS) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.top, AppTheme.spacingL)
        .padding(.bottom, AppTheme.spacingS)
    }
}

/// A dismissible error banner that displays a message with a red warning icon.
struct ErrorBannerView: View {

    /// The error message to display.
    let message: String

    /// An optional closure called when the user taps the dismiss button.
    var onDismiss: (() -> Void)? = nil

    /// Renders the warning icon, message text, and an optional dismiss button.
    var body: some View {
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(AppTheme.spacingM)
        .background(Color.red.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "accessibility_error") + ": " + message)
    }
}

/// A non-dismissible success banner that displays a message with a green checkmark icon.
struct SuccessBannerView: View {

    /// The success message to display.
    let message: String

    /// Renders the checkmark icon and message text on a green-tinted background.
    var body: some View {
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(AppTheme.spacingM)
        .background(Color.green.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }
}

/// A centered empty-state view with a large icon, title, and subtitle.
struct EmptyStateView: View {

    /// The SF Symbols name of the large icon.
    let icon: String

    /// The primary headline text.
    let title: String

    /// The secondary descriptive text shown below the title.
    let subtitle: String

    /// Renders the icon, title, and subtitle in a centered vertical stack.
    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spacingXL)
        .frame(maxWidth: .infinity)
    }
}

/// A reusable labeled text field that supports both regular and secure input.
struct AppTextField: View {

    /// The caption label displayed above the input field.
    let label: String

    /// A binding to the text being edited.
    @Binding var text: String

    /// Placeholder text shown when the field is empty.
    var placeholder: String = ""

    /// The keyboard type for the field.
    var keyboardType: UIKeyboardType = .default

    /// The auto-capitalization behaviour for the field.
    var autocapitalization: TextInputAutocapitalization = .sentences

    /// When `true`, renders a `SecureField` instead of a `TextField`.
    var isSecure: Bool = false

    /// Renders the label and the appropriate text field variant.
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(AppTheme.spacingM)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .padding(AppTheme.spacingM)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
}

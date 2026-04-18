import SwiftUI

/// A detail screen showing the insured person's insurance status and key identifying data.
///
/// Displays a gradient header card, personal data section (name, birth date), and insurance
/// data section (insurance number, pension number, tax ID). All numbers support text selection.
struct InsuranceStatusView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) private var colorScheme

    /// Shared date formatter producing long-style date strings without a time component.
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()

    /// Renders the gradient header and two data cards, or a progress indicator while loading.
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingM) {
                // Header-Karte
                ZStack {
                    AppTheme.headerGradient

                    VStack(spacing: AppTheme.spacingS) {
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.white.opacity(0.9))

                        Text(String(localized: "insurance_status_title"))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)

                        if let person = viewModel.person {
                            Text(String(localized: "insurance_status_valid"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, AppTheme.spacingXL)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                .padding(.horizontal, AppTheme.spacingM)

                if let person = viewModel.person {
                    // Persönliche Daten
                    StatusSectionCard(
                        title: String(localized: "insurance_section_personal"),
                        icon: "person.fill"
                    ) {
                        StatusRow(
                            label: String(localized: "insurance_field_name"),
                            value: person.fullName,
                            icon: "person"
                        )
                        Divider().padding(.leading, 40)
                        StatusRow(
                            label: String(localized: "insurance_field_birth"),
                            value: dateFormatter.string(from: person.birthDate),
                            icon: "calendar"
                        )
                    }
                    .padding(.horizontal, AppTheme.spacingM)

                    // Versicherungsdaten
                    StatusSectionCard(
                        title: String(localized: "insurance_section_insurance"),
                        icon: "cross.circle.fill"
                    ) {
                        StatusRow(
                            label: String(localized: "insurance_field_number"),
                            value: person.insuranceNumber,
                            icon: "number.circle",
                            isMonospaced: true
                        )
                        Divider().padding(.leading, 40)
                        StatusRow(
                            label: String(localized: "insurance_field_pension"),
                            value: person.pensionInsuranceNumber,
                            icon: "building.columns",
                            isMonospaced: true
                        )
                        Divider().padding(.leading, 40)
                        StatusRow(
                            label: String(localized: "insurance_field_tax_id"),
                            value: person.taxId,
                            icon: "doc.text",
                            isMonospaced: true
                        )
                    }
                    .padding(.horizontal, AppTheme.spacingM)

                    // Hinweis
                    HStack(spacing: AppTheme.spacingS) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(AppTheme.primary)
                        Text(String(localized: "insurance_status_hint"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
                    .padding(.horizontal, AppTheme.spacingM)

                } else {
                    ProgressView()
                        .padding(.top, AppTheme.spacingXXL)
                }

                Spacer(minLength: AppTheme.spacingXXL)
            }
            .padding(.top, AppTheme.spacingM)
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "profile_insurance_status-unknow"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadPerson(context: modelContext)
        }
    }
}

/// A card container with a labelled section header and generic view builder content.
///
/// Used on the insurance status screen to group related data rows under a titled, icon-labelled header.
struct StatusSectionCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    /// The section header title text.
    let title: String

    /// The SF Symbols icon shown beside the title.
    let icon: String

    /// The rows or other content displayed inside the card.
    @ViewBuilder let content: Content

    /// Renders the section header and content card with adaptive light/dark background and shadow.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.primary)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingS)

            VStack(spacing: 0) {
                content
            }
            .background(colorScheme == .dark ? Color(.secondarySystemBackground) : .white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            .shadow(
                color: colorScheme == .dark ? .black.opacity(0.2) : .black.opacity(0.05),
                radius: 8, x: 0, y: 3
            )
        }
    }
}

/// A single labeled data row with an optional SF Symbols icon and monospaced value rendering.
struct StatusRow: View {

    /// The caption label describing the value.
    let label: String

    /// The value string to display. Text selection is always enabled.
    let value: String

    /// An optional SF Symbols name shown to the left of the label and value.
    var icon: String = "info.circle"

    /// When `true`, renders the value in a monospaced font for better readability of identifiers.
    var isMonospaced: Bool = false

    /// Renders the icon, label, and selectable value side by side.
    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(AppTheme.primary.opacity(0.7))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(isMonospaced ? .system(.subheadline, design: .monospaced).weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, AppTheme.spacingS + 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

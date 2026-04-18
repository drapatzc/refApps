import SwiftUI

/// A screen that provides an overview of sick-pay (Krankengeld) information.
///
/// Shows an introductory text and a single entry row that navigates to a
/// "in development" placeholder screen.
struct SickPayView: View {

    /// Renders the introductory section and the sick-pay entry row.
    var body: some View {
        List {
            Section {
                Text(String(localized: "sick_pay_intro"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: AppTheme.spacingM,
                                              leading: AppTheme.spacingM,
                                              bottom: AppTheme.spacingM,
                                              trailing: AppTheme.spacingM))
            }

            Section {
                NavigationLink {
                    PlaceholderView(
                        title: String(localized: "placeholder_in_development_title"),
                        icon: "hammer.fill"
                    )
                } label: {
                    SickPayRow(
                        icon: "banknote.fill",
                        tint: Color(red: 0.80, green: 0.25, blue: 0.25),
                        title: String(localized: "sick_pay_all_payments_title"),
                        subtitle: String(localized: "sick_pay_all_payments_subtitle")
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "sick_pay_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Row

/// A styled list row for the sick-pay screen showing an icon, title, and subtitle.
private struct SickPayRow: View {

    /// The SF Symbols icon name.
    let icon: String

    /// The tint color applied to the icon and its background.
    let tint: Color

    /// The primary row label.
    let title: String

    /// The secondary descriptive text shown below the title.
    let subtitle: String

    /// Renders the icon container and text stack in a horizontal layout.
    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(tint.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(subtitle)")
    }
}

#Preview {
    NavigationStack {
        SickPayView()
    }
}

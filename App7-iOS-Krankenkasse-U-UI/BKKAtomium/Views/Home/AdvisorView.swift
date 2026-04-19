import SwiftUI

struct AdvisorView: View {
    private let phoneURL  = URL(string: "tel:020145678900")
    private let emailURL  = URL(string: "mailto:m.weber@bkk-atomium.de")

    var body: some View {
        List {
            Section {
                VStack(spacing: AppTheme.spacingM) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Text("MW")
                            .font(.title.weight(.bold))
                            .foregroundStyle(AppTheme.primary)
                    }
                    VStack(spacing: 4) {
                        Text("Michael Weber")
                            .font(.title3.weight(.bold))
                        Text("Kundenberater")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingM)
                .listRowBackground(AppTheme.primary.opacity(0.04))
            }

            Section(header: Text("Kontaktmöglichkeiten")) {
                if let url = phoneURL {
                    Link(destination: url) {
                        ContactActionRow(
                            icon: "phone.fill",
                            color: Color(red: 0.20, green: 0.60, blue: 0.40),
                            title: "Telefon",
                            value: "0201 456 789 00"
                        )
                    }
                }
                if let url = emailURL {
                    Link(destination: url) {
                        ContactActionRow(
                            icon: "envelope.fill",
                            color: Color(red: 0.11, green: 0.29, blue: 0.50),
                            title: "E-Mail",
                            value: "m.weber@bkk-atomium.de"
                        )
                    }
                }
            }

            Section(header: Text("Sprechzeiten")) {
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(AppTheme.primary.opacity(0.7))
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Mo – Fr: 8:00 – 17:00 Uhr")
                            .font(.subheadline.weight(.semibold))
                        Text("Sa & So: Nicht verfügbar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 3)
            }

            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.primary.opacity(0.7))
                        .font(.subheadline)
                    Text("Außerhalb der Sprechzeiten erreichen Sie uns über die kostenfreie Servicenummer 0800 1111 2222.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(AppTheme.primary.opacity(0.05))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "contact_advisor_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct ContactActionRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack { AdvisorView() }
}

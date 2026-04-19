import SwiftUI

struct HotlineView: View {
    let title: String
    let number: String
    let description: String
    let hours: String
    let note: String
    let color: Color

    private var callURL: URL? { URL(string: "tel:\(number.filter { $0.isNumber })") }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                // Hero card
                VStack(spacing: AppTheme.spacingM) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "phone.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(color)
                    }
                    Text(number)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("Kostenloser Anruf · 24/7")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    if let url = callURL {
                        Link(destination: url) {
                            Label("Jetzt anrufen", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.spacingM)
                                .background(color)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
                        }
                        .padding(.top, AppTheme.spacingXS)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.spacingL)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                .padding(.horizontal, AppTheme.spacingM)

                // Info
                VStack(spacing: AppTheme.spacingS) {
                    infoRow(icon: "info.circle.fill", color: color, title: "Leistung", body: description)
                    infoRow(icon: "clock.fill",        color: color, title: "Erreichbarkeit", body: hours)
                    infoRow(icon: "exclamationmark.circle.fill", color: .orange, title: "Hinweis", body: note)
                }
                .padding(.horizontal, AppTheme.spacingM)

                Spacer(minLength: AppTheme.spacingXXL)
            }
            .padding(.top, AppTheme.spacingM)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.groupedBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }

    private func infoRow(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 18))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacingM)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        HotlineView(
            title: "Arztterminservice",
            number: "116 117",
            description: "Über den ärztlichen Bereitschaftsdienst erhalten Sie schnell einen Arzttermin.",
            hours: "24 Stunden täglich, 7 Tage die Woche",
            note: "Im lebensbedrohlichen Notfall wählen Sie bitte 112.",
            color: Color(red: 0.20, green: 0.60, blue: 0.40)
        )
    }
}

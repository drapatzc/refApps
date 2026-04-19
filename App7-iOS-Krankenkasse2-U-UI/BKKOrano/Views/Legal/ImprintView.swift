import SwiftUI

struct ImprintView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                header(icon: "info.circle.fill",
                       title: String(localized: "profile_imprint"))

                entry(
                    title: String(localized: "imprint_provider"),
                    body: "BKK Orano\nRot-Weiss-Essen Straße 1907\n45147 Essen\nDeutschland"
                )
                entry(
                    title: String(localized: "imprint_contact"),
                    body: "Telefon: 0800 1111 2222\nE-Mail: info@bkk-orano.de"
                )
                entry(
                    title: String(localized: "imprint_legal_form"),
                    body: "Körperschaft des öffentlichen Rechts"
                )
                entry(
                    title: String(localized: "imprint_authority"),
                    body: "Bundesamt für Soziale Sicherung"
                )
                entry(
                    title: String(localized: "imprint_board"),
                    body: "Dr. Anna Werner (Vorstandsvorsitzende)"
                )
                entry(
                    title: String(localized: "imprint_disclaimer"),
                    body: "Diese App enthält Demo-Inhalte und dient ausschließlich Präsentationszwecken."
                )

                Text(String(localized: "legal_last_updated"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, AppTheme.spaceM)
            }
            .padding(AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "profile_imprint"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func header(icon: String, title: String) -> some View {
        HStack(spacing: AppTheme.spaceM) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(AppTheme.actionGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            Text(title)
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
        }
    }

    private func entry(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(AppTheme.primary)
            Text(body)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
        }
        .padding(AppTheme.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.primaryDeep.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

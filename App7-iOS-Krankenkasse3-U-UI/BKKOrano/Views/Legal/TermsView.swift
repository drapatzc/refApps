import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                header(icon: "doc.plaintext.fill",
                       title: String(localized: "profile_terms"))

                block(
                    heading: "§ 1 Geltungsbereich",
                    body: "Diese Nutzungsbedingungen gelten für die Nutzung der BKK Orano App durch Versicherte der BKK Orano."
                )
                block(
                    heading: "§ 2 Leistungen",
                    body: "Die App stellt digitale Services wie Krankmeldungen, Adressverwaltung und Kontostand zur Verfügung. Einzelne Funktionen können jederzeit erweitert oder eingeschränkt werden."
                )
                block(
                    heading: "§ 3 Nutzerpflichten",
                    body: "Die Nutzung erfolgt eigenverantwortlich. Zugangsdaten sind sicher aufzubewahren und nicht an Dritte weiterzugeben."
                )
                block(
                    heading: "§ 4 Verfügbarkeit",
                    body: "Wir bemühen uns um eine hohe Verfügbarkeit, eine permanente Verfügbarkeit kann aber nicht garantiert werden."
                )

                Text(String(localized: "legal_last_updated"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, AppTheme.spaceM)
            }
            .padding(AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "profile_terms"))
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
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
        }
    }

    private func block(heading: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(heading)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
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

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spaceL) {
                header(icon: "hand.raised.fill",
                       title: String(localized: "profile_privacy"))

                block(
                    heading: "1. Datenverantwortung",
                    body: "Verantwortlich für die Verarbeitung Ihrer Daten ist die BKK Orano. Wir verarbeiten Ihre personenbezogenen Daten ausschließlich zur Durchführung unserer gesetzlichen Aufgaben als Krankenkasse."
                )
                block(
                    heading: "2. Welche Daten erheben wir?",
                    body: "Stammdaten, Kontaktdaten und Versicherungsdaten, die Sie uns in der App zur Verfügung stellen. Diese Daten werden verschlüsselt übertragen und gespeichert."
                )
                block(
                    heading: "3. Ihre Rechte",
                    body: "Sie haben das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung der Verarbeitung sowie das Recht auf Widerspruch und Datenübertragbarkeit."
                )
                block(
                    heading: "4. Kontakt Datenschutz",
                    body: "Datenschutzbeauftragte(r):\ndatenschutz@bkk-orano.de"
                )

                Text(String(localized: "legal_last_updated"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, AppTheme.spaceM)
            }
            .padding(AppTheme.spaceL)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
        .navigationTitle(String(localized: "profile_privacy"))
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

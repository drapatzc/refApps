import SwiftUI

/// A screen that displays the privacy policy as a styled legal document.
struct PrivacyView: View {

    /// Renders the privacy policy using `LegalDocumentView` with the standard privacy icon.
    var body: some View {
        LegalDocumentView(
            title: String(localized: "profile_privacy"),
            icon: "lock.shield.fill",
            sections: PrivacyContent.sections
        )
    }
}

/// A reusable scrollable legal document screen with a title, icon, and a list of named sections.
struct LegalDocumentView: View {

    /// The document title shown in the header and navigation bar.
    let title: String

    /// The SF Symbols name displayed beside the title in the header.
    let icon: String

    /// The ordered list of sections that make up the document body.
    let sections: [LegalSection]

    /// Renders the header, a divider, and each `LegalSectionView` in a vertical scroll view.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                // Header
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.title2.weight(.bold))
                        Text(String(localized: "legal_last_updated"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingM)

                Divider()

                ForEach(sections.indices, id: \.self) { index in
                    LegalSectionView(section: sections[index])
                        .padding(.horizontal, AppTheme.spacingM)
                }

                Spacer(minLength: AppTheme.spacingXXL)
            }
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A value type representing a single titled section within a legal document.
struct LegalSection {

    /// The section heading (e.g. a numbered paragraph title).
    let title: String

    /// The body text of the section.
    let body: String
}

/// A view that renders a single `LegalSection` with a bold headline and secondary body text.
struct LegalSectionView: View {

    /// The section data to render.
    let section: LegalSection

    /// Renders the section title in bold and the body text in secondary style.
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(section.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(section.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Static content provider for the privacy policy document.
///
/// Defines the eight GDPR-compliant sections shown in `PrivacyView`.
enum PrivacyContent {

    /// The ordered privacy policy sections.
    static let sections: [LegalSection] = [
        LegalSection(
            title: "1. Verantwortliche Stelle",
            body: "Verantwortlich für die Verarbeitung Ihrer personenbezogenen Daten ist die BKK Atomium, Hauptstraße 1, 10115 Berlin. Datenschutzbeauftragter: datenschutz@bkk-atomium.de"
        ),
        LegalSection(
            title: "2. Erhebung und Verarbeitung personenbezogener Daten",
            body: "Wir verarbeiten Ihre personenbezogenen Daten ausschließlich zur Erfüllung unserer gesetzlichen Aufgaben als Krankenkasse gemäß SGB V sowie zur Bereitstellung unserer digitalen Dienste. Rechtsgrundlage ist Art. 6 Abs. 1 lit. c DSGVO in Verbindung mit den Vorschriften des SGB."
        ),
        LegalSection(
            title: "3. Arten der verarbeiteten Daten",
            body: "Wir verarbeiten folgende Kategorien personenbezogener Daten: Stammdaten (Name, Geburtsdatum, Adresse), Kontaktdaten (Telefon, E-Mail), Gesundheitsdaten im Rahmen der Krankenversicherung, Bankverbindungsdaten zur Abwicklung von Erstattungen sowie technische Nutzungsdaten dieser App."
        ),
        LegalSection(
            title: "4. Weitergabe an Dritte",
            body: "Eine Weitergabe Ihrer Daten an Dritte erfolgt nur, soweit dies gesetzlich vorgeschrieben oder zulässig ist. Dies betrifft insbesondere Leistungserbringer im Gesundheitswesen, andere Sozialversicherungsträger sowie staatliche Stellen im Rahmen gesetzlicher Verpflichtungen."
        ),
        LegalSection(
            title: "5. Speicherdauer",
            body: "Ihre personenbezogenen Daten werden gelöscht oder gesperrt, sobald der Zweck der Speicherung entfällt und keine gesetzlichen Aufbewahrungsfristen entgegenstehen. Im Bereich der gesetzlichen Krankenversicherung gelten in der Regel Aufbewahrungsfristen von 10 Jahren."
        ),
        LegalSection(
            title: "6. Ihre Rechte",
            body: "Sie haben das Recht auf Auskunft (Art. 15 DSGVO), Berichtigung (Art. 16 DSGVO), Löschung (Art. 17 DSGVO), Einschränkung der Verarbeitung (Art. 18 DSGVO), Datenübertragbarkeit (Art. 20 DSGVO) sowie das Widerspruchsrecht (Art. 21 DSGVO). Zur Wahrnehmung Ihrer Rechte wenden Sie sich bitte an: datenschutz@bkk-atomium.de"
        ),
        LegalSection(
            title: "7. Beschwerderecht",
            body: "Sie haben das Recht, sich bei der zuständigen Aufsichtsbehörde zu beschweren. Die zuständige Aufsichtsbehörde ist der Bundesbeauftragte für den Datenschutz und die Informationsfreiheit (BfDI), Graurheindorfer Str. 153, 53117 Bonn."
        ),
        LegalSection(
            title: "8. Datensicherheit",
            body: "Wir setzen technische und organisatorische Sicherheitsmaßnahmen ein, um Ihre Daten gegen zufällige oder vorsätzliche Manipulation, Verlust, Zerstörung oder den Zugriff unberechtigter Personen zu schützen. Unsere Sicherheitsmaßnahmen werden entsprechend der technologischen Entwicklung fortlaufend verbessert."
        )
    ]
}

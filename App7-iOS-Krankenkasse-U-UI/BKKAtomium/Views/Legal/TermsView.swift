import SwiftUI

/// A screen that displays the terms of use as a styled legal document.
struct TermsView: View {

    /// Renders the terms of use using `LegalDocumentView` with the standard document icon.
    var body: some View {
        LegalDocumentView(
            title: String(localized: "profile_terms"),
            icon: "doc.plaintext.fill",
            sections: TermsContent.sections
        )
    }
}

/// Static content provider for the terms of use document.
///
/// Defines the eight paragraphs shown in `TermsView`.
enum TermsContent {

    /// The ordered terms of use sections.
    static let sections: [LegalSection] = [
        LegalSection(
            title: "§ 1 Geltungsbereich",
            body: "Diese Nutzungsbedingungen gelten für die Nutzung der BKK Atomium App sowie aller damit verbundenen digitalen Dienste. Durch die Nutzung der App erklären Sie sich mit diesen Bedingungen einverstanden."
        ),
        LegalSection(
            title: "§ 2 Nutzungsvoraussetzungen",
            body: "Die App steht ausschließlich Mitgliedern der BKK Atomium zur Verfügung. Für die Nutzung ist ein gültiges Mitgliedschaftsverhältnis erforderlich. Mit Beendigung der Mitgliedschaft erlischt das Nutzungsrecht."
        ),
        LegalSection(
            title: "§ 3 Zugangsdaten",
            body: "Sie sind verpflichtet, Ihre Zugangsdaten vertraulich zu behandeln und vor dem Zugriff Dritter zu schützen. Bei Verdacht auf Missbrauch oder unbefugten Zugriff informieren Sie uns unverzüglich unter service@bkk-atomium.de oder der Telefonnummer 0800 123 4567."
        ),
        LegalSection(
            title: "§ 4 Funktionsumfang",
            body: "Die BKK Atomium App ermöglicht die Verwaltung Ihrer Versicherungsdaten, die Einreichung von Dokumenten, die Kommunikation mit Ihrer Krankenkasse sowie weitere versicherungsbezogene Dienste. Der genaue Funktionsumfang kann sich im Laufe der Zeit ändern."
        ),
        LegalSection(
            title: "§ 5 Verfügbarkeit",
            body: "Wir bemühen uns um eine hohe Verfügbarkeit der App, können jedoch keine ununterbrochene Verfügbarkeit garantieren. Wartungsarbeiten, technische Störungen oder höhere Gewalt können zu vorübergehenden Einschränkungen führen."
        ),
        LegalSection(
            title: "§ 6 Haftungsbeschränkung",
            body: "Die BKK Atomium haftet nicht für Schäden, die durch die Nutzung oder Nichtnutzbarkeit der App entstehen, sofern diese nicht auf grober Fahrlässigkeit oder Vorsatz beruhen. Gesetzliche Haftungsansprüche bleiben unberührt."
        ),
        LegalSection(
            title: "§ 7 Änderungen",
            body: "Wir behalten uns vor, diese Nutzungsbedingungen jederzeit zu ändern. Sie werden über wesentliche Änderungen per Push-Notification oder E-Mail informiert. Die fortgesetzte Nutzung der App nach Inkrafttreten der Änderungen gilt als Zustimmung."
        ),
        LegalSection(
            title: "§ 8 Anwendbares Recht",
            body: "Es gilt das Recht der Bundesrepublik Deutschland. Ausschließlicher Gerichtsstand ist Berlin, soweit gesetzlich zulässig."
        )
    ]
}

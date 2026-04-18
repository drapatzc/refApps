import SwiftUI

/// A screen that displays the legal imprint (Impressum) of the BKK Atomium app.
///
/// Shows provider address, contact details, legal form, supervisory authority,
/// board members, and a liability disclaimer in a scrollable layout.
struct ImprintView: View {

    /// Renders the imprint header and all `ImprintBlock` sections.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingL) {
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "profile_imprint"))
                            .font(.title2.weight(.bold))
                        Text(String(localized: "legal_last_updated"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingM)

                Divider()

                ImprintBlock(title: String(localized: "imprint_provider")) {
                    Text("BKK Atomium\nHauptstraße 1\n10115 Berlin\nDeutschland")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ImprintBlock(title: String(localized: "imprint_contact")) {
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Label("0800 123 4567 (kostenlos)", systemImage: "phone.fill")
                        Label("service@bkk-atomium.de", systemImage: "envelope.fill")
                        Label("www.bkk-atomium.de", systemImage: "globe")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                ImprintBlock(title: String(localized: "imprint_legal_form")) {
                    Text("Körperschaft des öffentlichen Rechts nach § 4 SGB V")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ImprintBlock(title: String(localized: "imprint_authority")) {
                    Text("Bundesamt für Soziale Sicherung\nFriedrich-Ebert-Allee 38\n53113 Bonn")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ImprintBlock(title: String(localized: "imprint_board")) {
                    Text("Vorstandsvorsitzender: Dr. Michael Steinberg\nStellvertreterin: Anna Friedmann")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ImprintBlock(title: String(localized: "imprint_disclaimer")) {
                    Text("Die BKK Atomium übernimmt keine Gewähr für die Vollständigkeit, Richtigkeit und Aktualität der bereitgestellten Informationen. Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine Haftung für die Inhalte externer Links. Für den Inhalt der verlinkten Seiten sind ausschließlich deren Betreiber verantwortlich.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppTheme.spacingXXL)
            }
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "profile_imprint"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A generic block that displays a bold section title followed by arbitrary view builder content.
///
/// Used throughout `ImprintView` to group related information under a readable heading.
struct ImprintBlock<Content: View>: View {

    /// The section heading text.
    let title: String

    /// The content to display below the heading.
    @ViewBuilder let content: Content

    /// Renders the title and content in a left-aligned vertical stack with horizontal padding.
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            content
        }
        .padding(.horizontal, AppTheme.spacingM)
    }
}

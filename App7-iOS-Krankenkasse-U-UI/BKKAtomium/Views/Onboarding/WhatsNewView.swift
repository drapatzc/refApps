import SwiftUI

// MARK: - Was-ist-neu Eintrag

private struct WhatsNewEntry: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let detail: String
}

private let whatsNewEntries: [WhatsNewEntry] = [
    WhatsNewEntry(
        icon: "chart.bar.fill",
        color: Color(red: 0.11, green: 0.29, blue: 0.50),
        title: "Kostendiagramm",
        detail: "Die Kostenübersicht zeigt Ihre monatlichen Ausgaben jetzt als interaktives Balkendiagramm."
    ),
    WhatsNewEntry(
        icon: "chart.pie.fill",
        color: Color(red: 0.95, green: 0.65, blue: 0.10),
        title: "Bonus-Aufschlüsselung",
        detail: "Das Bonusprogramm zeigt eine Kategorieaufteilung Ihrer gesammelten Maßnahmen als Donut-Chart."
    ),
    WhatsNewEntry(
        icon: "bolt.fill",
        color: Color(red: 0.20, green: 0.60, blue: 0.40),
        title: "Schnellzugriff-Buttons",
        detail: "Im Dashboard erreichen Sie Krankmeldung, Kontakt und Postfach jetzt mit einem Tap."
    ),
    WhatsNewEntry(
        icon: "bell.badge.fill",
        color: Color(red: 0.80, green: 0.25, blue: 0.25),
        title: "Beitragsanpassung",
        detail: "Wichtige Hinweise zur Beitragsanpassung erscheinen direkt im Dashboard als Banner."
    ),
    WhatsNewEntry(
        icon: "arrow.clockwise",
        color: Color(red: 0.55, green: 0.25, blue: 0.75),
        title: "Pull-to-Refresh",
        detail: "Rechnungen und Dokumente lassen sich jetzt per Ziehen aktualisieren."
    )
]

// MARK: - Was ist neu View

/// Sheet, das nach dem Onboarding oder beim Start einer neuen Version einmalig erscheint.
struct WhatsNewView: View {
    /// Callback nach Bestätigung durch den Nutzer.
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: "sparkles")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppTheme.primary)
                        .symbolEffect(.bounce, value: appeared)
                }
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(duration: 0.55, bounce: 0.3), value: appeared)

                VStack(spacing: 6) {
                    Text("Was ist neu?")
                        .font(.largeTitle.weight(.bold))
                    Text("Version 1.2")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(duration: 0.45).delay(0.1), value: appeared)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)

            // Einträge
            VStack(spacing: 0) {
                ForEach(Array(whatsNewEntries.enumerated()), id: \.offset) { index, entry in
                    WhatsNewRow(entry: entry)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                        .animation(.spring(duration: 0.45).delay(0.15 + Double(index) * 0.07), value: appeared)

                    if index < whatsNewEntries.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 20)

            Spacer(minLength: 24)

            // Bestätigen-Button
            Button {
                onDismiss()
            } label: {
                Text("Los geht's")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.spring(duration: 0.45).delay(0.55), value: appeared)
        }
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// MARK: - Zeile

private struct WhatsNewRow: View {
    let entry: WhatsNewEntry

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(entry.color.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(entry.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                Text(entry.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    WhatsNewView(onDismiss: {})
}

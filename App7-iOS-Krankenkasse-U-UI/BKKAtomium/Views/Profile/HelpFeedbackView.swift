import SwiftUI

private struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct HelpFeedbackView: View {
    @State private var expandedID: UUID? = nil
    @State private var showFeedback = false

    private let faqItems: [FAQItem] = [
        FAQItem(
            question: "Wie reiche ich eine Krankmeldung ein?",
            answer: "Über den Tab 'Start' → 'Krankmeldung' können Sie Ihre Arbeitsunfähigkeitsbescheinigung bequem digital einscannen und einreichen."
        ),
        FAQItem(
            question: "Wie beantrage ich eine neue Gesundheitskarte?",
            answer: "Unter 'Service' → 'Karte verloren' können Sie Ihre Karte sperren und eine neue Gesundheitskarte beantragen. Diese wird innerhalb von 7–10 Werktagen zugeschickt."
        ),
        FAQItem(
            question: "Wann erhalte ich mein Krankengeld?",
            answer: "Krankengeld wird ab dem 43. Krankheitstag gezahlt, wenn Ihnen der Arbeitgeber kein Gehalt mehr zahlt. Die Auszahlung erfolgt monatlich im Nachhinein."
        ),
        FAQItem(
            question: "Wie funktioniert das Bonusprogramm?",
            answer: "Reichen Sie Nachweise für gesundheitsbewusstes Verhalten ein (z. B. Vorsorgeuntersuchungen, Sportnachweis). Pro Maßnahme erhalten Sie bis zu 30 €. Ab 200 € pro Jahr können Sie eine Prämie beantragen."
        ),
        FAQItem(
            question: "Welche Bescheinigungen kann ich anfordern?",
            answer: "Über 'Service' → 'Bescheinigungen' können Sie Mitgliedsbescheinigungen, Beitragsbescheinigungen, Zuzahlungsbefreiungen und mehr anfordern."
        )
    ]

    var body: some View {
        List {
            Section(header: Text("Häufige Fragen")) {
                ForEach(faqItems) { item in
                    FAQRow(item: item, expandedID: $expandedID)
                }
            }

            Section(header: Text("Support")) {
                NavigationLink {
                    SecureMessageView()
                } label: {
                    HelpRow(icon: "envelope.fill", color: AppTheme.primary, title: "Kontaktanfrage senden", subtitle: "Wir antworten innerhalb von 2 Werktagen")
                }

                if let url = URL(string: "tel:080011112222") {
                    Link(destination: url) {
                        HelpRow(icon: "phone.fill", color: Color(red: 0.20, green: 0.60, blue: 0.40), title: "Kundendienst anrufen", subtitle: "0800 1111 2222 · Kostenlos · 24/7")
                    }
                }
            }

            Section(header: Text("Feedback")) {
                Button {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id0") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HelpRow(icon: "star.fill", color: Color(red: 0.95, green: 0.65, blue: 0.10), title: "App bewerten", subtitle: "Ihre Meinung ist uns wichtig")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    PraiseComplaintsView()
                } label: {
                    HelpRow(icon: "exclamationmark.bubble.fill", color: Color(red: 0.55, green: 0.25, blue: 0.75), title: "Lob und Beschwerde", subtitle: "Teilen Sie uns Ihre Erfahrung mit")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "profile_help_feedback"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct FAQRow: View {
    let item: FAQItem
    @Binding var expandedID: UUID?

    private var isExpanded: Bool { expandedID == item.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedID = isExpanded ? nil : item.id
                }
            } label: {
                HStack {
                    Text(item.question)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: AppTheme.spacingS)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

private struct HelpRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

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
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack { HelpFeedbackView() }
}

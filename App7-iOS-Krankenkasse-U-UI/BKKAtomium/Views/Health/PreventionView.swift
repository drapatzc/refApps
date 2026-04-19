import SwiftUI

enum PreventionStatus {
    case done, due, overdue, pending

    var label: String {
        switch self {
        case .done:    return "Durchgeführt"
        case .due:     return "Fällig"
        case .overdue: return "Überfällig"
        case .pending: return "Ausstehend"
        }
    }

    var color: Color {
        switch self {
        case .done:    return Color(red: 0.20, green: 0.60, blue: 0.40)
        case .due:     return Color(red: 0.95, green: 0.65, blue: 0.10)
        case .overdue: return Color(red: 0.80, green: 0.25, blue: 0.25)
        case .pending: return .secondary
        }
    }

    var icon: String {
        switch self {
        case .done:    return "checkmark.circle.fill"
        case .due:     return "clock.fill"
        case .overdue: return "exclamationmark.circle.fill"
        case .pending: return "circle"
        }
    }
}

struct PreventionItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: PreventionStatus
    let lastDate: String?
}

struct PreventionView: View {
    private let screenings: [PreventionItem] = [
        PreventionItem(title: "Check-up 35+",       detail: "Allgemeine Gesundheitsuntersuchung",  status: .done,    lastDate: "14.02.2025"),
        PreventionItem(title: "Zahnvorsorge",        detail: "Zweimal jährlich empfohlen",          status: .due,     lastDate: "02.01.2025"),
        PreventionItem(title: "Hautkrebsscreening",  detail: "Alle 2 Jahre ab 35",                  status: .overdue, lastDate: "15.03.2022"),
        PreventionItem(title: "Darmkrebsfrüherkennung", detail: "Stuhltest oder Darmspiegelung",    status: .done,    lastDate: "10.09.2023"),
        PreventionItem(title: "Mammographie",        detail: "Alle 2 Jahre, 50–69 Jahre",           status: .pending, lastDate: nil),
        PreventionItem(title: "Augendruckmessung",   detail: "Auf ärztlichen Rat",                  status: .pending, lastDate: nil)
    ]

    var body: some View {
        List {
            Section {
                Text("Vorsorgeuntersuchungen helfen, Krankheiten früh zu erkennen. Die BKK Atomium übernimmt die Kosten für alle gesetzlich vorgeschriebenen Früherkennungsmaßnahmen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            Section(header: Text("Früherkennungsuntersuchungen")) {
                ForEach(screenings) { item in
                    PreventionRow(item: item)
                }
            }

            Section {
                Link(destination: URL(string: "https://www.krebsfrueherkennung.de")!) {
                    HStack {
                        Image(systemName: "safari.fill")
                            .foregroundStyle(AppTheme.primary)
                        Text("Weitere Informationen (krebsfrueherkennung.de)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "health_prevention_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct PreventionRow: View {
    let item: PreventionItem

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: item.status.icon)
                .font(.system(size: 22))
                .foregroundStyle(item.status.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let last = item.lastDate {
                    Text("Zuletzt: \(last)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text(item.status.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(item.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(item.status.color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { PreventionView() }
}

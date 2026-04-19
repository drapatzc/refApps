import SwiftUI

struct eAUEntry: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let issuer: String
    let diagnosis: String
    let isReceived: Bool
}

struct eAUView: View {
    private let entries: [eAUEntry] = [
        eAUEntry(from: "10.03.2025", to: "14.03.2025", issuer: "Hausarztpraxis Dr. Schmidt",    diagnosis: "Akute Atemwegsinfektion (J06.9)",  isReceived: true),
        eAUEntry(from: "22.01.2025", to: "24.01.2025", issuer: "Hausarztpraxis Dr. Schmidt",    diagnosis: "Grippaler Infekt (J11.1)",          isReceived: true),
        eAUEntry(from: "05.11.2024", to: "06.11.2024", issuer: "Internistische Praxis Dr. Müller", diagnosis: "Magen-Darm-Erkrankung (A09)",    isReceived: true)
    ]

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.primary.opacity(0.7))
                    Text("Ihr Arzt übermittelt eAU-Bescheinigungen direkt digital an uns. Sie müssen nichts weiterleiten.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(AppTheme.primary.opacity(0.06))
            }

            if entries.isEmpty {
                Section {
                    VStack(spacing: AppTheme.spacingM) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary.opacity(0.35))
                        Text("Keine Bescheinigungen")
                            .font(.headline)
                        Text("Eingereichte eAU-Bescheinigungen erscheinen hier.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingXL)
                    .listRowBackground(Color.clear)
                }
            } else {
                Section(header: Text("Einreichungsverlauf")) {
                    ForEach(entries) { entry in
                        eAURow(entry: entry)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "health_eau_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct eAURow: View {
    let entry: eAUEntry

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.10, green: 0.45, blue: 0.55).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.45, blue: 0.55))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(entry.from) – \(entry.to)")
                    .font(.subheadline.weight(.semibold))
                Text(entry.issuer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.diagnosis)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                Text("Erhalten")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack { eAUView() }
}

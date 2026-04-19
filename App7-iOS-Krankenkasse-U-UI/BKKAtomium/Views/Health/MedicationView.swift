import SwiftUI

struct MedicationEntry: Identifiable {
    let id = UUID()
    let name: String
    let dosage: String
    let frequency: String
    let icon: String
    let color: Color
    let prescribedBy: String
    let since: String
}

struct MedicationView: View {
    private let medications: [MedicationEntry] = [
        MedicationEntry(
            name: "Pantoprazol",
            dosage: "20 mg",
            frequency: "1× täglich, morgens nüchtern",
            icon: "pills.fill",
            color: Color(red: 0.55, green: 0.25, blue: 0.75),
            prescribedBy: "Dr. Schmidt",
            since: "Seit 01.02.2025"
        ),
        MedicationEntry(
            name: "Metformin",
            dosage: "500 mg",
            frequency: "2× täglich, morgens und abends",
            icon: "pills.fill",
            color: Color(red: 0.11, green: 0.29, blue: 0.50),
            prescribedBy: "Dr. Müller",
            since: "Seit 15.09.2024"
        ),
        MedicationEntry(
            name: "Vitamin D3",
            dosage: "1000 IE",
            frequency: "1× täglich, zum Essen",
            icon: "sun.max.fill",
            color: Color(red: 0.95, green: 0.65, blue: 0.10),
            prescribedBy: "Dr. Schmidt",
            since: "Seit 01.10.2024"
        )
    ]

    var body: some View {
        List {
            Section {
                Text("Ihre aktuell verordneten Medikamente im Überblick.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            Section(header: Text("Aktuelle Medikamente")) {
                ForEach(medications) { med in
                    MedicationRow(entry: med)
                }
            }

            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.subheadline)
                    Text("Diese Liste dient nur zur Übersicht. Bitte konsultieren Sie Ihren Arzt vor jeder Änderung der Medikation.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.orange.opacity(0.06))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "health_medication_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct MedicationRow: View {
    let entry: MedicationEntry

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(entry.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(entry.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(entry.name)
                        .font(.subheadline.weight(.semibold))
                    Text(entry.dosage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(entry.frequency)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.since + " · " + entry.prescribedBy)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { MedicationView() }
}

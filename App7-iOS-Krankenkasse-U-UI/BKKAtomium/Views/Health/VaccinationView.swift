import SwiftUI

struct VaccinationRecord: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let nextDue: String?
    let isUpToDate: Bool
    let color: Color
}

struct VaccinationView: View {
    private let records: [VaccinationRecord] = [
        VaccinationRecord(name: "Influenza",            date: "05.10.2024", nextDue: "Okt. 2025",    isUpToDate: true,  color: Color(red: 0.20, green: 0.60, blue: 0.40)),
        VaccinationRecord(name: "COVID-19 (Auffrischung)", date: "12.11.2023", nextDue: nil,          isUpToDate: true,  color: Color(red: 0.11, green: 0.29, blue: 0.50)),
        VaccinationRecord(name: "Tetanus / Diphtherie",    date: "15.03.2022", nextDue: "2032",       isUpToDate: true,  color: Color(red: 0.10, green: 0.45, blue: 0.55)),
        VaccinationRecord(name: "Pneumokokken",            date: "22.04.2020", nextDue: nil,          isUpToDate: true,  color: Color(red: 0.55, green: 0.25, blue: 0.75)),
        VaccinationRecord(name: "Masern / Mumps / Röteln", date: "22.06.1995", nextDue: nil,          isUpToDate: true,  color: Color(red: 0.80, green: 0.45, blue: 0.15)),
        VaccinationRecord(name: "Hepatitis B",             date: "–",          nextDue: "Empfohlen",  isUpToDate: false, color: Color(red: 0.80, green: 0.25, blue: 0.25))
    ]

    var body: some View {
        List {
            Section {
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(records.filter(\.isUpToDate).count) von \(records.count) Impfungen")
                            .font(.headline.weight(.bold))
                        Text("aktuell und vollständig")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, AppTheme.spacingXS)
                .listRowBackground(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.08))
            }

            Section(header: Text("Impfübersicht")) {
                ForEach(records) { record in
                    VaccinationRow(record: record)
                }
            }

            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.primary.opacity(0.7))
                        .font(.subheadline)
                    Text("Schutzimpfungen werden von der BKK Atomium gemäß den STIKO-Empfehlungen vollständig übernommen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(AppTheme.primary.opacity(0.05))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "health_vaccination_title"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct VaccinationRow: View {
    let record: VaccinationRecord

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(record.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "syringe.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(record.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(record.name)
                    .font(.subheadline.weight(.semibold))
                Text("Impfdatum: \(record.date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let due = record.nextDue {
                    Text("Nächste Auffrischung: \(due)")
                        .font(.caption2)
                        .foregroundStyle(record.isUpToDate ? Color.secondary.opacity(0.6) : Color(red: 0.80, green: 0.25, blue: 0.25))
                }
            }

            Spacer()

            Image(systemName: record.isUpToDate ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(record.isUpToDate ? Color(red: 0.20, green: 0.60, blue: 0.40) : Color(red: 0.80, green: 0.25, blue: 0.25))
                .font(.system(size: 18))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { VaccinationView() }
}

import SwiftUI
import Foundation

/// Represents a sick-pay period with duration, amounts, and status.
struct SickPayPeriod {
    let startDate: Date
    let endDate: Date
    let dailyRate: Double
    let isActive: Bool

    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    var totalAmount: Double {
        Double(duration) * dailyRate
    }

    var status: String {
        isActive ? "Laufend" : "Abgeschlossen"
    }
}

/// A screen that provides an overview of sick-pay (Krankengeld) information.
///
/// Shows sick-pay periods with details and a calculator to compute daily rates based on salary.
struct SickPayView: View {
    @State private var selectedSalary: Double = 45000

    private let sickPayPeriods: [SickPayPeriod] = [
        SickPayPeriod(
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 5))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 26))!,
            dailyRate: 68.50,
            isActive: false
        ),
        SickPayPeriod(
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!,
            dailyRate: 68.50,
            isActive: true
        )
    ]

    var body: some View {
        List {
            Section(header: Text("Krankengeldperioden")) {
                if sickPayPeriods.isEmpty {
                    Text("Keine Krankengeldperioden verfügbar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sickPayPeriods.sorted { $0.startDate > $1.startDate }, id: \.startDate) { period in
                        SickPayPeriodRow(period: period)
                    }
                }
            }

            Section(header: Text("Rechner")) {
                VStack(spacing: AppTheme.spacingM) {
                    HStack {
                        Text("Jahresgehalt:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("Gehalt", value: $selectedSalary, format: .number)
                            .frame(width: 120)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }

                    let dailyRate = (selectedSalary / 365) * 0.70
                    let monthlyExample = dailyRate * 30

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Tagesatz (ca. 70%):")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.2f €", dailyRate))
                                .font(.headline)
                                .foregroundStyle(AppTheme.primary)
                        }

                        HStack {
                            Text("Monatlich (ca.):")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.2f €", monthlyExample))
                                .font(.headline)
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.sectionBackground)
                    .cornerRadius(AppTheme.cornerRadiusL)
                }
                .padding(.vertical, AppTheme.spacingS)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Krankengeld")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// A row displaying a single sick-pay period.
private struct SickPayPeriodRow: View {
    let period: SickPayPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            HStack(spacing: AppTheme.spacingM) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(period.startDate.formatted(date: .abbreviated, time: .omitted) +
                         " – " +
                         period.endDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("\(period.duration) Tage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.2f €", period.totalAmount))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(period.status)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(period.isActive ? .orange : .green)
                }
            }

            HStack(spacing: AppTheme.spacingL) {
                HStack(spacing: 4) {
                    Text("Tagesatz:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f €", period.dailyRate))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("Status:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: period.isActive ? "circle.fill" : "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(period.isActive ? .orange : .green)
                }
            }
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.sectionBackground)
        .cornerRadius(AppTheme.cornerRadiusL)
    }
}

#Preview {
    NavigationStack {
        SickPayView()
    }
}

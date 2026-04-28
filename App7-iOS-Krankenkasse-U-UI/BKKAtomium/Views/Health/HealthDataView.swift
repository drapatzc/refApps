import SwiftUI
import Charts

// MARK: - Vital Entry Model

private struct VitalEntry {
    let icon: String
    let color: Color
    let title: String
    let value: String
    let unit: String
    let date: String
    let trend: [Double]
}

// MARK: - Health Data View

struct HealthDataView: View {
    @State private var appeared = false

    private let vitals: [VitalEntry] = [
        VitalEntry(
            icon: "heart.fill",
            color: Color(red: 0.80, green: 0.25, blue: 0.25),
            title: "Blutdruck",
            value: "118/76",
            unit: "mmHg",
            date: "Vor 14 Tagen",
            trend: [128, 125, 124, 121, 120, 119, 118]
        ),
        VitalEntry(
            icon: "waveform.path.ecg",
            color: Color(red: 0.80, green: 0.25, blue: 0.25),
            title: "Herzfrequenz",
            value: "72",
            unit: "bpm",
            date: "Heute",
            trend: [78, 76, 74, 75, 73, 72, 72]
        ),
        VitalEntry(
            icon: "scalemass.fill",
            color: Color(red: 0.11, green: 0.29, blue: 0.50),
            title: "Gewicht",
            value: "78,4",
            unit: "kg",
            date: "Vor 7 Tagen",
            trend: [79.2, 78.9, 78.7, 78.6, 78.5, 78.4, 78.4]
        ),
        VitalEntry(
            icon: "drop.fill",
            color: Color(red: 0.95, green: 0.55, blue: 0.15),
            title: "Blutzucker",
            value: "98",
            unit: "mg/dL",
            date: "Vor 21 Tagen",
            trend: [104, 101, 99, 100, 98, 99, 98]
        ),
        VitalEntry(
            icon: "figure.stand",
            color: Color(red: 0.20, green: 0.60, blue: 0.40),
            title: "BMI",
            value: "24,1",
            unit: "",
            date: "Berechnet",
            trend: [24.5, 24.4, 24.3, 24.2, 24.2, 24.1, 24.1]
        ),
        VitalEntry(
            icon: "flask.fill",
            color: Color(red: 0.55, green: 0.25, blue: 0.75),
            title: "Cholesterin",
            value: "190",
            unit: "mg/dL",
            date: "Vor 30 Tagen",
            trend: [198, 195, 193, 192, 191, 190, 190]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                sectionHeader("Vitalwerte")

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: AppTheme.spacingM
                ) {
                    ForEach(Array(vitals.enumerated()), id: \.offset) { index, v in
                        VitalCard(
                            icon: v.icon,
                            color: v.color,
                            title: v.title,
                            value: v.value,
                            unit: v.unit,
                            date: v.date,
                            trend: v.trend
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(
                            .bouncy(duration: 0.5).delay(Double(index) * 0.07),
                            value: appeared
                        )
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)

                infoNote(icon: "applehealth", text: "Demo-Daten. In einer Echtanbindung werden Werte aus der Apple-Gesundheits-App oder Ihrer ePA übernommen.")

                Spacer(minLength: AppTheme.spacingXXL)
            }
            .padding(.top, AppTheme.spacingM)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.groupedBackground)
        .navigationTitle(String(localized: "health_data_title"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spacingM)
    }

    private func infoNote(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.spacingS) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(AppTheme.primary.opacity(0.7))
                .font(.subheadline)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        .padding(.horizontal, AppTheme.spacingM)
    }
}

// MARK: - Vital Card

private struct VitalCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    let unit: String
    let date: String
    let trend: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            // Icon mit .bounce beim Erscheinen
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(color)
                    .symbolEffect(.bounce, options: .nonRepeating)
            }

            // Wert
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(date)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Sparkline — 7-Tage-Verlauf
            if trend.count > 1 {
                Chart {
                    ForEach(Array(trend.enumerated()), id: \.offset) { i, val in
                        AreaMark(
                            x: .value("", i),
                            y: .value("", val)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color.opacity(0.28), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("", i),
                            y: .value("", val)
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                        .foregroundStyle(color)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
                .frame(height: 30)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacingM)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack { HealthDataView() }
}

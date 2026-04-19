import SwiftUI

struct HealthDataView: View {
    @State private var appeared = false

    private let vitals: [(icon: String, color: Color, title: String, value: String, unit: String, date: String)] = [
        ("heart.fill",          Color(red: 0.80, green: 0.25, blue: 0.25), "Blutdruck",     "118/76", "mmHg", "Vor 14 Tagen"),
        ("waveform.path.ecg",   Color(red: 0.80, green: 0.25, blue: 0.25), "Herzfrequenz",  "72",     "bpm",  "Heute"),
        ("scalemass.fill",      Color(red: 0.11, green: 0.29, blue: 0.50), "Gewicht",        "78,4",   "kg",   "Vor 7 Tagen"),
        ("drop.fill",           Color(red: 0.95, green: 0.55, blue: 0.15), "Blutzucker",    "98",     "mg/dL","Vor 21 Tagen"),
        ("figure.stand",        Color(red: 0.20, green: 0.60, blue: 0.40), "BMI",           "24,1",   "",     "Berechnet"),
        ("flask.fill",          Color(red: 0.55, green: 0.25, blue: 0.75), "Cholesterin",   "190",    "mg/dL","Vor 30 Tagen")
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
                            date: v.date
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.07), value: appeared)
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

private struct VitalCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    let unit: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(color)
            }
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

import SwiftUI

struct SettingsView: View {
    @State private var pushEnabled       = true
    @State private var bonusReminders    = true
    @State private var appointmentAlerts = false
    @State private var biometricsEnabled = true
    @State private var appearanceIndex   = 0

    private let appearanceOptions = ["Systemeinstellung", "Hell", "Dunkel"]

    var body: some View {
        List {
            Section(header: Text("Benachrichtigungen")) {
                Toggle(isOn: $pushEnabled) {
                    SettingsRow(icon: "bell.fill", color: Color(red: 0.80, green: 0.25, blue: 0.25), title: "Push-Benachrichtigungen")
                }
                .disabled(!pushEnabled && !bonusReminders)

                Toggle(isOn: $bonusReminders) {
                    SettingsRow(icon: "star.fill", color: Color(red: 0.95, green: 0.65, blue: 0.10), title: "Bonus-Erinnerungen")
                }
                .disabled(!pushEnabled)

                Toggle(isOn: $appointmentAlerts) {
                    SettingsRow(icon: "calendar.badge.clock", color: Color(red: 0.20, green: 0.60, blue: 0.40), title: "Vorsorge-Termine")
                }
                .disabled(!pushEnabled)
            }

            Section(header: Text("Darstellung")) {
                HStack {
                    SettingsRow(icon: "paintbrush.fill", color: Color(red: 0.55, green: 0.25, blue: 0.75), title: "Erscheinungsbild")
                    Spacer()
                    Picker("", selection: $appearanceIndex) {
                        ForEach(Array(appearanceOptions.enumerated()), id: \.offset) { index, opt in
                            Text(opt).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section(header: Text("Sicherheit")) {
                Toggle(isOn: $biometricsEnabled) {
                    SettingsRow(icon: "faceid", color: AppTheme.primary, title: "Face ID / Touch ID")
                }
            }

            Section(header: Text("Info")) {
                SettingsInfoRow(label: "Version",         value: "1.0.0")
                SettingsInfoRow(label: "Build",           value: "2025.04.19")
                SettingsInfoRow(label: "Betriebssystem",  value: "iOS 17+")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "profile_settings"))
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct SettingsRow: View {
    let icon: String
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.body)
        }
    }
}

private struct SettingsInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}

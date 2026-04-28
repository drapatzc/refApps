import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SettingsViewModel()
    @State private var showLogoutAlert = false
    @State private var biometricEnabled = false

    var body: some View {
        List {
            Section(header: Text(String(localized: "settings_section_notifications"))) {
                Toggle(isOn: $viewModel.pushEnabled) {
                    SettingsRow(icon: "bell.fill", color: Color(red: 0.80, green: 0.25, blue: 0.25), title: String(localized: "settings_notification_push"))
                }

                Toggle(isOn: $viewModel.bonusReminders) {
                    SettingsRow(icon: "star.fill", color: Color(red: 0.95, green: 0.65, blue: 0.10), title: String(localized: "settings_notification_bonus"))
                }

                Toggle(isOn: $viewModel.preventionAlerts) {
                    SettingsRow(icon: "calendar.badge.clock", color: Color(red: 0.20, green: 0.60, blue: 0.40), title: String(localized: "settings_notification_prevention"))
                }
            }

            Section(header: Text(String(localized: "settings_section_appearance"))) {
                VStack(spacing: AppTheme.spacingM) {
                    HStack(spacing: AppTheme.spacingM) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.55, green: 0.25, blue: 0.75).opacity(0.15))
                                .frame(width: 30, height: 30)
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(red: 0.55, green: 0.25, blue: 0.75))
                        }
                        Text(String(localized: "settings_appearance_mode"))
                            .font(.body)
                    }

                    Picker(String(localized: "settings_appearance_mode"), selection: $viewModel.appearanceIndex) {
                        Text(String(localized: "settings_appearance_system")).tag(0)
                        Text(String(localized: "settings_appearance_light")).tag(1)
                        Text(String(localized: "settings_appearance_dark")).tag(2)
                    }
                    .pickerStyle(.segmented)
                }
            }

            Section(header: Text(String(localized: "settings_section_security"))) {
                Toggle(isOn: $biometricEnabled) {
                    SettingsRow(icon: "faceid", color: AppTheme.primary, title: String(localized: "settings_security_biometric"))
                }
                .disabled(!appState.isBiometricAvailable)
                .onChange(of: biometricEnabled) {
                    appState.isBiometricEnabled = biometricEnabled
                }
            }

            Section(header: Text("Info")) {
                SettingsInfoRow(label: String(localized: "settings_app_version"), value: "1.0.0")
                SettingsInfoRow(label: String(localized: "settings_build"), value: "2025.04.19")
                SettingsInfoRow(label: "iOS", value: "17+")
            }

            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.backward")
                        Text(String(localized: "profile_logout"))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "settings_title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(String(localized: "profile_logout_confirm_title"), isPresented: $showLogoutAlert) {
            Button(String(localized: "common_cancel"), role: .cancel) {}
            Button(String(localized: "profile_logout"), role: .destructive) {
                appState.logout()
            }
        } message: {
            Text(String(localized: "profile_logout_confirm_message"))
        }
        .onAppear {
            viewModel.setup(appState: appState)
            biometricEnabled = appState.isBiometricEnabled
        }
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

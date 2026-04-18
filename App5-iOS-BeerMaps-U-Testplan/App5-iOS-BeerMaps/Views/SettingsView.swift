import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("section_username", comment: ""))) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.accentColor)
                        Text(viewModel.username)
                            .font(.headline)
                    }

                    Button {
                        viewModel.pendingUsername = viewModel.username
                        viewModel.showUsernameEditor = true
                    } label: {
                        Label(NSLocalizedString("edit_username", comment: ""), systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        viewModel.resetToRandomUsername()
                    } label: {
                        Label(NSLocalizedString("reset_username", comment: ""), systemImage: "arrow.counterclockwise")
                    }
                }

                Section(header: Text(NSLocalizedString("section_notifications", comment: ""))) {
                    HStack {
                        Image(systemName: notificationIcon)
                            .foregroundColor(notificationColor)
                        Text(NSLocalizedString("notification_status", comment: ""))
                        Spacer()
                        Text(notificationStatusText)
                            .foregroundColor(.secondary)
                    }

                    if viewModel.notificationStatus != .authorized {
                        Button {
                            Task { await viewModel.requestNotificationPermission() }
                        } label: {
                            Label(NSLocalizedString("request_notification_permission", comment: ""), systemImage: "bell.badge")
                        }
                    }

                    if viewModel.notificationStatus == .authorized {
                        Button {
                            Task { await viewModel.sendTestNotification() }
                        } label: {
                            Label(NSLocalizedString("send_test_notification", comment: ""), systemImage: "bell.fill")
                        }
                    }
                }

                Section(header: Text(NSLocalizedString("section_about", comment: ""))) {
                    LabeledContent(NSLocalizedString("app_version", comment: ""), value: appVersion)
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
            .onAppear {
                Task { await viewModel.loadNotificationStatus() }
            }
            .alert(NSLocalizedString("edit_username", comment: ""), isPresented: $viewModel.showUsernameEditor) {
                TextField(NSLocalizedString("username_placeholder", comment: ""), text: $viewModel.pendingUsername)
                Button(NSLocalizedString("save", comment: "")) {
                    viewModel.saveUsername(viewModel.pendingUsername)
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var notificationIcon: String {
        switch viewModel.notificationStatus {
        case .authorized: return "bell.fill"
        case .denied: return "bell.slash.fill"
        default: return "bell"
        }
    }

    private var notificationColor: Color {
        switch viewModel.notificationStatus {
        case .authorized: return .green
        case .denied: return .red
        default: return .orange
        }
    }

    private var notificationStatusText: String {
        switch viewModel.notificationStatus {
        case .authorized: return NSLocalizedString("notification_authorized", comment: "")
        case .denied: return NSLocalizedString("notification_denied", comment: "")
        case .notDetermined: return NSLocalizedString("notification_not_determined", comment: "")
        default: return NSLocalizedString("notification_not_determined", comment: "")
        }
    }
}

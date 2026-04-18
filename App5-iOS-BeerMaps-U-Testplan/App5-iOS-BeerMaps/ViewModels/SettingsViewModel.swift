import Foundation
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var showUsernameEditor: Bool = false
    @Published var pendingUsername: String = ""

    private let keychainService: KeychainServiceProtocol
    private let notificationService: NotificationServiceProtocol

    init(keychainService: KeychainServiceProtocol = KeychainService.shared,
         notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.keychainService = keychainService
        self.notificationService = notificationService
        loadUsername()
    }

    func loadUsername() {
        username = UsernameGenerator.validUsername(from: keychainService.load(key: KeychainKeys.username),
                                                   keychainService: keychainService)
    }

    func saveUsername(_ newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        _ = keychainService.save(key: KeychainKeys.username, value: trimmed)
        username = trimmed
    }

    func resetToRandomUsername() {
        let newName = UsernameGenerator.generateUsername()
        _ = keychainService.save(key: KeychainKeys.username, value: newName)
        username = newName
    }

    func loadNotificationStatus() async {
        notificationStatus = await notificationService.getAuthorizationStatus()
    }

    func requestNotificationPermission() async {
        _ = await notificationService.requestAuthorization()
        await loadNotificationStatus()
    }

    func sendTestNotification() async {
        await notificationService.scheduleLocalNotification(
            title: NSLocalizedString("test_notification_title", comment: ""),
            body: NSLocalizedString("test_notification_body", comment: ""),
            identifier: "test-notification-\(UUID().uuidString)"
        )
    }
}

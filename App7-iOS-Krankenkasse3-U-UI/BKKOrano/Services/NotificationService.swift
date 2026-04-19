import UserNotifications
import UIKit

final class NotificationService: NSObject {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private override init() { super.init() }

    func requestAuthorization() {
        Task {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    await MainActor.run { registerForRemoteNotifications() }
                }
            } catch {
                print("Push-Berechtigung fehlgeschlagen: \(error)")
            }
        }
    }

    @MainActor
    private func registerForRemoteNotifications() {
        #if !targetEnvironment(simulator)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func scheduleLocalNotification(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        delay: TimeInterval = 5
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Lokale Benachrichtigung fehlgeschlagen: \(error)")
            }
        }
    }

    func scheduleDemoNotification() {
        scheduleLocalNotification(
            id: "orano_demo",
            title: String(localized: "notification_demo_title"),
            body: String(localized: "notification_demo_body"),
            delay: 3
        )
    }

    func clearBadge() {
        Task { @MainActor in
            try? await UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}

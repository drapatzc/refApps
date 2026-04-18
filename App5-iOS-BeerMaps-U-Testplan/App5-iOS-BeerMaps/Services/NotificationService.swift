import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization() async -> Bool
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    func scheduleLocalNotification(title: String, body: String, identifier: String) async
    func removeAllPendingNotifications()
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    func scheduleLocalNotification(title: String, body: String, identifier: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

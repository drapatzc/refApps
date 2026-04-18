import UserNotifications
import UIKit

/// A singleton service that manages push and local notifications.
///
/// `NotificationService` requests authorization, registers for remote notifications,
/// schedules local demo notifications, clears the app badge, and cancels pending
/// notification requests.
final class NotificationService: NSObject {

    /// The shared singleton instance.
    static let shared = NotificationService()

    /// The underlying notification center used for all scheduling and settings queries.
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    // MARK: - Berechtigung

    /// Requests notification authorization (alert, sound, badge) from the user.
    ///
    /// If authorization is granted, registers for remote notifications on the main actor.
    /// Errors are logged to the console.
    func requestAuthorization() {
        Task {
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    await MainActor.run {
                        registerForRemoteNotifications()
                    }
                }
            } catch {
                print("Push-Berechtigung fehlgeschlagen: \(error)")
            }
        }
    }

    /// Calls `UIApplication.registerForRemoteNotifications()` on real devices only.
    ///
    /// This call is skipped when running on the simulator to avoid an unsupported-operation error.
    @MainActor
    private func registerForRemoteNotifications() {
        #if !targetEnvironment(simulator)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
    }

    /// Returns the current notification authorization status.
    ///
    /// - Returns: The `UNAuthorizationStatus` value reported by the system.
    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Lokale Benachrichtigungen (für Tests / Demo)

    /// Schedules a local notification to be delivered after a configurable delay.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the request; defaults to a new UUID string.
    ///   - title: The notification title.
    ///   - body: The notification body text.
    ///   - delay: The delay in seconds before the notification fires; defaults to 5.
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

    /// Schedules a branded demo notification that fires after a 3-second delay.
    ///
    /// Title and body are loaded from the app's localized string catalog.
    func scheduleDemoNotification() {
        scheduleLocalNotification(
            id: "bkk_demo",
            title: String(localized: "notification_demo_title"),
            body: String(localized: "notification_demo_body"),
            delay: 3
        )
    }

    /// Resets the app's badge count to zero.
    func clearBadge() {
        Task { @MainActor in
            try? await UNUserNotificationCenter.current()
                .setBadgeCount(0)
        }
    }

    /// Removes all pending (not yet delivered) notification requests.
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}

import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Push Notification Manager

struct PushToastContent {
    let title: String
    let body: String
    let actions: [UNNotificationAction]
}

@MainActor
final class PushNotificationManager: ObservableObject {
    static let shared = PushNotificationManager()
    @Published var toast: PushToastContent? = nil
    private var dismissTask: Task<Void, Never>?
    private init() {}

    func show(_ content: PushToastContent) {
        dismissTask?.cancel()
        withAnimation(.easeInOut(duration: 0.35)) { toast = content }
        guard content.actions.isEmpty else { return }
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.35)) { toast = nil }
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeInOut(duration: 0.35)) { toast = nil }
    }
}

// MARK: - App

@main
struct App5_iOS_BeerMapsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([DrinkEntry.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var registeredCategories: [String: UNNotificationCategory] = [:]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
        return true
    }

    private func registerNotificationCategories() {
        let replyAction = UNNotificationAction(
            identifier: "REPLY_ACTION",
            title: NSLocalizedString("push_action_reply", comment: ""),
            options: [.foreground]
        )
        let replyCategory = UNNotificationCategory(
            identifier: "REPLY_ACTION",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        let yesAction = UNNotificationAction(
            identifier: "YES_ACTION",
            title: NSLocalizedString("push_action_yes", comment: ""),
            options: []
        )
        let noAction = UNNotificationAction(
            identifier: "NO_ACTION",
            title: NSLocalizedString("push_action_no", comment: ""),
            options: [.destructive]
        )
        let yesNoCategory = UNNotificationCategory(
            identifier: "YES_NO_ACTION",
            actions: [yesAction, noAction],
            intentIdentifiers: [],
            options: []
        )
        let allCategories: Set<UNNotificationCategory> = [replyCategory, yesNoCategory]
        for cat in allCategories { registeredCategories[cat.identifier] = cat }
        UNUserNotificationCenter.current().setNotificationCategories(allCategories)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        let actions = registeredCategories[content.categoryIdentifier]?.actions ?? []
        Task { @MainActor in
            PushNotificationManager.shared.show(PushToastContent(
                title: content.title,
                body: content.body,
                actions: actions
            ))
        }
        completionHandler([.sound, .badge])
    }
}

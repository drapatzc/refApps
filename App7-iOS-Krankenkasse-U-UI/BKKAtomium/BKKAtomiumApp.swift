import SwiftUI
import SwiftData
import UserNotifications

/// The application entry point for BKK Atomium.
///
/// `BKKAtomiumApp` configures the SwiftData `ModelContainer`, injects the shared
/// `AppState` into the environment, and requests push-notification authorization
/// on first launch.
@main
struct BKKAtomiumApp: App {

    /// The shared, observable application state injected into every view.
    @State private var appState = AppState()

    /// The UIKit application delegate, wired up via `@UIApplicationDelegateAdaptor`.
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    /// The persistent SwiftData model container for the full app schema.
    ///
    /// Includes `InsuredPerson`, `Address`, `PhoneNumber`, `BankAccount`, and
    /// `EmailAddress`. Crashes with a `fatalError` if the container cannot be
    /// created (which should never happen in a correctly configured build).
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InsuredPerson.self,
            Address.self,
            PhoneNumber.self,
            BankAccount.self,
            EmailAddress.self,
            Invoice.self,
            InsuranceDocument.self,
            BenefitRequest.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer konnte nicht erstellt werden: \(error)")
        }
    }()

    /// The root scene, wiring up `RootView` with the shared state and model container.
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    NotificationService.shared.requestAuthorization()
                }
        }
    }
}

/// The top-level routing view that switches between the login and main-tab flows.
///
/// `RootView` observes `AppState.isLoggedIn` and animates the transition between
/// `LoginView` and `MainTabView`. It also seeds the SwiftData store with mock data
/// on first launch via `MockDataSeeder`.
struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    /// Renders either `MainTabView` or `LoginView` depending on authentication state,
    /// with a smooth opacity-and-scale transition.
    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.isLoggedIn)
        .preferredColorScheme(appState.colorSchemeOverride)
        .task {
            await MockDataSeeder.seedIfNeeded(context: modelContext)
        }
        .overlay(alignment: .top) {
            if let toast = appState.toastMessage {
                VStack(spacing: 0) {
                    HStack(spacing: AppTheme.spacingM) {
                        Image(systemName: toast.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(toast.message)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Spacer()
                    }
                    .padding(AppTheme.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(toast.isSuccess ? Color.green : Color.red)
                    .cornerRadius(AppTheme.cornerRadiusM)
                    .padding(AppTheme.spacingM)

                    Spacer()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.toastMessage)
    }
}

/// The UIKit application delegate, responsible for remote-notification registration
/// and foreground notification presentation.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    /// Sets the notification center delegate immediately after launch.
    ///
    /// - Parameters:
    ///   - application: The shared application instance.
    ///   - launchOptions: A dictionary of launch options provided by the system.
    /// - Returns: `true` to indicate successful initialization.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// Logs the APNs device token received after successful remote-notification registration.
    ///
    /// - Parameters:
    ///   - application: The shared application instance.
    ///   - deviceToken: The unique device token assigned by APNs.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("APNs Device Token: \(tokenString)")
    }

    /// Presents notifications with banner, sound, and badge while the app is in the foreground.
    ///
    /// - Parameters:
    ///   - center: The notification center.
    ///   - notification: The notification that is about to be delivered.
    /// - Returns: The presentation options to apply.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }
}

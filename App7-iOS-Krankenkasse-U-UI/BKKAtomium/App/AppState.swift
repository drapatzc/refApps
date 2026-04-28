import SwiftUI
import Observation

/// Represents a toast notification message.
struct ToastMessage: Identifiable, Equatable {
    let id: UUID
    let message: String
    let isSuccess: Bool

    init(message: String, isSuccess: Bool) {
        self.id = UUID()
        self.message = message
        self.isSuccess = isSuccess
    }

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id && lhs.message == rhs.message && lhs.isSuccess == rhs.isSuccess
    }
}

/// Observable application-level state shared across the entire view hierarchy.
///
/// `AppState` holds authentication status and the currently signed-in user's
/// basic identifying information. It is injected into the environment via
/// `.environment(appState)` from `BKKAtomiumApp`.
@Observable
final class AppState {

    /// Whether the user is currently authenticated.
    var isLoggedIn: Bool = false

    /// The full name of the currently authenticated user.
    var currentUserName: String = ""

    /// The insurance number of the currently authenticated user.
    var currentInsuranceNumber: String = ""

    /// Indicates that an asynchronous operation is in progress.
    var isLoading: Bool = false

    /// An error message to be displayed to the user, or `nil` when there is no error.
    var errorMessage: String? = nil

    /// Whether biometric authentication is enabled.
    var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometric.enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometric.enabled") }
    }

    /// Whether the device supports biometric authentication.
    var isBiometricAvailable: Bool = false

    /// Color scheme override for dark mode support (nil = system default).
    var colorSchemeOverride: ColorScheme? = nil

    /// Cached monthly insurance premium.
    var monthlyPremium: Double = 0.0

    /// Currently selected tab in the main tab view.
    var selectedTab: String = "home"

    /// Current toast notification message, or nil if none is displayed.
    var toastMessage: ToastMessage? = nil

    /// Transitions the application into the authenticated state.
    ///
    /// - Parameters:
    ///   - name: The full name of the user who just logged in.
    ///   - insuranceNumber: The insurance number associated with the user.
    func login(name: String, insuranceNumber: String) {
        currentUserName = name
        currentInsuranceNumber = insuranceNumber
        isLoggedIn = true
    }

    /// Resets all authentication-related state and transitions back to the login screen.
    func logout() {
        isLoggedIn = false
        currentUserName = ""
        currentInsuranceNumber = ""
        errorMessage = nil
    }

    /// Displays a toast notification message for 3 seconds.
    ///
    /// - Parameters:
    ///   - message: The message to display.
    ///   - isSuccess: Whether this is a success (green) or error (red) message.
    @MainActor
    func showToast(message: String, isSuccess: Bool) {
        toastMessage = ToastMessage(message: message, isSuccess: isSuccess)
        Task {
            try? await Task.sleep(for: .seconds(3))
            toastMessage = nil
        }
    }
}

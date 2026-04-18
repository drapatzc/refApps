import SwiftUI
import Observation

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
}

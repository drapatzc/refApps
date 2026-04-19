import SwiftUI
import Observation

@Observable
final class AppState {
    var isLoggedIn: Bool = false
    var currentUserName: String = ""
    var currentInsuranceNumber: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    func login(name: String, insuranceNumber: String) {
        currentUserName = name
        currentInsuranceNumber = insuranceNumber
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        currentUserName = ""
        currentInsuranceNumber = ""
        errorMessage = nil
    }
}

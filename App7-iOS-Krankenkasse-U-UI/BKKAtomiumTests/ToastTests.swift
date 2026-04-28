import Testing
import SwiftUI
@testable import BKKAtomium

@Suite("Toast Notifications")
@MainActor
struct ToastTests {

    @Test("Show success toast")
    func showSuccessToast() async {
        let appState = AppState()

        await appState.showToast(message: "Test Success", isSuccess: true)

        #expect(appState.toastMessage != nil)
        #expect(appState.toastMessage?.message == "Test Success")
        #expect(appState.toastMessage?.isSuccess == true)
    }

    @Test("Show error toast")
    func showErrorToast() async {
        let appState = AppState()

        await appState.showToast(message: "Test Error", isSuccess: false)

        #expect(appState.toastMessage != nil)
        #expect(appState.toastMessage?.message == "Test Error")
        #expect(appState.toastMessage?.isSuccess == false)
    }

    @Test("Toast auto-dismisses after delay")
    func toastAutoDismisses() async {
        let appState = AppState()

        await appState.showToast(message: "Auto Dismiss Test", isSuccess: true)
        #expect(appState.toastMessage != nil)

        try? await Task.sleep(for: .seconds(3.5))
        #expect(appState.toastMessage == nil)
    }

    @Test("ToastMessage is equatable")
    func toastMessageEquatable() {
        let msg1 = AppState.ToastMessage(id: UUID(), message: "Test", isSuccess: true)
        let msg2 = AppState.ToastMessage(id: msg1.id, message: "Test", isSuccess: true)

        #expect(msg1 == msg2)
    }

    @Test("Toast message has unique ID")
    func toastMessageUniqueID() {
        let msg1 = AppState.ToastMessage(id: UUID(), message: "Test 1", isSuccess: true)
        let msg2 = AppState.ToastMessage(id: UUID(), message: "Test 2", isSuccess: false)

        #expect(msg1.id != msg2.id)
    }
}

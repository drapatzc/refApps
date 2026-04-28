import Testing
@testable import BKKAtomium

@Suite("AppState Tests")
struct AppStateTests {

    @Test("Initialer Zustand ist ausgeloggt mit leeren Feldern")
    func testInitialState() {
        let state = AppState()
        #expect(state.isLoggedIn == false)
        #expect(state.currentUserName == "")
        #expect(state.currentInsuranceNumber == "")
        #expect(state.isLoading == false)
        #expect(state.errorMessage == nil)
    }

    @Test("login() setzt isLoggedIn auf true und speichert Nutzerdaten")
    func testLoginSetsState() {
        let state = AppState()
        state.login(name: "Christian Drapatz", insuranceNumber: "A987654321")
        #expect(state.isLoggedIn == true)
        #expect(state.currentUserName == "Christian Drapatz")
        #expect(state.currentInsuranceNumber == "A987654321")
    }

    @Test("logout() setzt alle Felder zurück")
    func testLogoutResetsState() {
        let state = AppState()
        state.login(name: "Test User", insuranceNumber: "B123456789")
        state.errorMessage = "Ein Fehler"
        state.logout()
        #expect(state.isLoggedIn == false)
        #expect(state.currentUserName == "")
        #expect(state.currentInsuranceNumber == "")
        #expect(state.errorMessage == nil)
    }

    @Test("Mehrfaches login() überschreibt vorherige Daten")
    func testLoginOverwritesPreviousData() {
        let state = AppState()
        state.login(name: "User A", insuranceNumber: "A000000001")
        state.login(name: "User B", insuranceNumber: "B000000002")
        #expect(state.currentUserName == "User B")
        #expect(state.currentInsuranceNumber == "B000000002")
        #expect(state.isLoggedIn == true)
    }

    @Test("logout() direkt nach Initialisierung ist stabil")
    func testLogoutFromInitialState() {
        let state = AppState()
        state.logout()
        #expect(state.isLoggedIn == false)
        #expect(state.currentUserName == "")
        #expect(state.errorMessage == nil)
    }

    @Test("isLoading kann gesetzt und gelesen werden")
    func testIsLoadingMutation() {
        let state = AppState()
        state.isLoading = true
        #expect(state.isLoading == true)
        state.isLoading = false
        #expect(state.isLoading == false)
    }

    @Test("errorMessage kann gesetzt und gelesen werden")
    func testErrorMessageMutation() {
        let state = AppState()
        state.errorMessage = "Verbindungsfehler"
        #expect(state.errorMessage == "Verbindungsfehler")
        state.errorMessage = nil
        #expect(state.errorMessage == nil)
    }
}

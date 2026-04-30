import Foundation
import Testing
@testable import BKKAtomium

/// Tests für das einheitliche Fehlerbehandlungssystem.
@Suite("AppError Tests")
struct AppErrorTests {

    // MARK: - AppError.Equatable

    @Test("Zwei identische AppError.unknown sind gleich")
    func testUnknownErrorEquality() {
        let first = AppError.unknown("Testfehler")
        let second = AppError.unknown("Testfehler")
        #expect(first == second)
    }

    @Test("Verschiedene AppError.unknown-Nachrichten sind ungleich")
    func testUnknownErrorInequality() {
        let first = AppError.unknown("Fehler A")
        let second = AppError.unknown("Fehler B")
        #expect(first != second)
    }

    @Test("AppError.auth(.emptyPassword) ist identisch")
    func testAuthErrorEquality() {
        let first = AppError.auth(.emptyPassword)
        let second = AppError.auth(.emptyPassword)
        #expect(first == second)
    }

    @Test("AppError.auth(.emptyPassword) ungleich auth(.invalidCredentials)")
    func testDifferentAuthErrorsUnequal() {
        let first = AppError.auth(.emptyPassword)
        let second = AppError.auth(.invalidCredentials)
        #expect(first != second)
    }

    @Test("AppError.persistence und AppError.unknown sind ungleich")
    func testDifferentTypesUnequal() {
        let first = AppError.persistence("Test")
        let second = AppError.unknown("Test")
        #expect(first != second)
    }

    // MARK: - AppError.LocalizedError

    @Test("AppError.auth(.emptyPassword) hat eine Fehlerbeschreibung")
    func testAuthErrorHasDescription() {
        let error = AppError.auth(.emptyPassword)
        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
    }

    @Test("AppError.persistence hat Präfix in Beschreibung")
    func testPersistenceErrorDescription() {
        let error = AppError.persistence("Datenbankfehler")
        let description = error.errorDescription ?? ""
        #expect(description.contains("Datenbankfehler"))
    }

    @Test("AppError.themeLoading hat Nachricht in Beschreibung")
    func testThemeLoadingErrorDescription() {
        let error = AppError.themeLoading("theme-ocean.json")
        let description = error.errorDescription ?? ""
        #expect(description.contains("theme-ocean.json"))
    }

    @Test("AppError.unknown hat Nachricht in Beschreibung")
    func testUnknownErrorDescription() {
        let error = AppError.unknown("Unerwarteter Systemfehler")
        let description = error.errorDescription ?? ""
        #expect(description.contains("Unerwarteter Systemfehler"))
    }
}

/// Tests für ErrorMapper.
@Suite("ErrorMapper Tests")
struct ErrorMapperTests {

    @Test("ErrorMapper.map(ValidationError) erzeugt AppError.validation")
    func testMapValidationError() {
        let validationError = ValidationError.empty(field: "Straße")
        let mapped = ErrorMapper.map(validationError)
        if case .validation(let inner) = mapped {
            #expect(inner.errorDescription == validationError.errorDescription)
        } else {
            #expect(Bool(false), "Erwarteter Typ: .validation")
        }
    }

    @Test("ErrorMapper.map(AuthError) erzeugt AppError.auth")
    func testMapAuthError() {
        let authError = AuthError.emptyPassword
        let mapped = ErrorMapper.map(authError)
        if case .auth(let inner) = mapped {
            #expect(inner == authError)
        } else {
            #expect(Bool(false), "Erwarteter Typ: .auth")
        }
    }

    @Test("ErrorMapper.map(AppError) gibt denselben AppError zurück")
    func testMapAppErrorIsIdentity() {
        let original = AppError.persistence("Test")
        let mapped = ErrorMapper.map(original)
        #expect(mapped == original)
    }

    @Test("ErrorMapper.map(NSError) fällt auf .unknown zurück")
    func testMapGenericErrorFallsBackToUnknown() {
        let nsError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Testfehler"])
        let mapped = ErrorMapper.map(nsError)
        if case .unknown = mapped {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Erwarteter Typ: .unknown")
        }
    }
}

/// Tests für ViewState.
@Suite("ViewState Tests")
struct ViewStateTests {

    @Test("ViewState.idle: isLoading ist false")
    func testIdleIsNotLoading() {
        let state: ViewState<String> = .idle
        #expect(state.isLoading == false)
        #expect(state.value == nil)
        #expect(state.error == nil)
        #expect(state.isLoaded == false)
        #expect(state.hasFailed == false)
    }

    @Test("ViewState.loading: isLoading ist true")
    func testLoadingState() {
        let state: ViewState<String> = .loading
        #expect(state.isLoading == true)
        #expect(state.value == nil)
        #expect(state.error == nil)
    }

    @Test("ViewState.loaded(value): value ist korrekt")
    func testLoadedState() {
        let state: ViewState<String> = .loaded("TestWert")
        #expect(state.isLoading == false)
        #expect(state.value == "TestWert")
        #expect(state.error == nil)
        #expect(state.isLoaded == true)
    }

    @Test("ViewState.failed(error): error ist korrekt")
    func testFailedState() {
        let error = AppError.unknown("Test")
        let state: ViewState<String> = .failed(error)
        #expect(state.isLoading == false)
        #expect(state.value == nil)
        #expect(state.error == error)
        #expect(state.hasFailed == true)
    }

    @Test("ViewState.idle == ViewState.idle (Equatable)")
    func testEquatableIdle() {
        let first: ViewState<String> = .idle
        let second: ViewState<String> = .idle
        #expect(first == second)
    }

    @Test("ViewState.loaded(a) != ViewState.loaded(b)")
    func testEquatableLoadedDifferent() {
        let first: ViewState<String> = .loaded("a")
        let second: ViewState<String> = .loaded("b")
        #expect(first != second)
    }

    @Test("ViewState.loading != ViewState.idle")
    func testEquatableLoadingVsIdle() {
        let loading: ViewState<String> = .loading
        let idle: ViewState<String> = .idle
        #expect(loading != idle)
    }
}

/// Tests für ErrorDialogViewModel.
@Suite("ErrorDialogViewModel Tests")
@MainActor
struct ErrorDialogViewModelTests {

    @Test("Initial ist kein Fehler vorhanden und Dialog nicht sichtbar")
    func testInitialState() {
        let viewModel = ErrorDialogViewModel()
        #expect(viewModel.currentError == nil)
        #expect(viewModel.isPresented == false)
    }

    @Test("present() setzt Fehler und isPresented auf true")
    func testPresentSetsError() {
        let viewModel = ErrorDialogViewModel()
        viewModel.present(.unknown("Testfehler"))
        #expect(viewModel.currentError != nil)
        #expect(viewModel.isPresented == true)
    }

    @Test("dismiss() löscht Fehler und setzt isPresented auf false")
    func testDismissClearsError() {
        let viewModel = ErrorDialogViewModel()
        viewModel.present(.unknown("Testfehler"))
        viewModel.dismiss()
        #expect(viewModel.currentError == nil)
        #expect(viewModel.isPresented == false)
    }

    @Test("present(anyError:) konvertiert beliebigen Fehler")
    func testPresentAnyError() {
        let viewModel = ErrorDialogViewModel()
        let nsError = NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "NSFehler"])
        viewModel.present(anyError: nsError)
        #expect(viewModel.isPresented == true)
        #expect(viewModel.currentError != nil)
    }
}

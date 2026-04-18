// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests for `CitySearchViewModel`.
/// Verifies city loading, search functionality, and city selection.
@MainActor
struct CitySearchViewModelTests {

    /// Creates the system under test together with its injected mock service.
    /// - Returns: A tuple of the configured `CitySearchViewModel` and its `MockWeatherService`.
    private func makeSUT() -> (viewModel: CitySearchViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        let viewModel = CitySearchViewModel(service: service)
        return (viewModel, service)
    }

    /// Returns a fixed list of three test cities covering two countries.
    private func testCities() -> [City] {
        [
            City(name: "Berlin",  land: "Germany", latitude: 52.52, longitude: 13.40),
            City(name: "Munich",  land: "Germany", latitude: 48.14, longitude: 11.58),
            City(name: "Paris",   land: "France",  latitude: 48.86, longitude:  2.35),
        ]
    }

    // MARK: - Initial State

    @Test("ViewModel has correct initial state")
    func viewModelHasCorrectInitialState() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.alleStaedte.isEmpty)
        #expect(viewModel.suchergebnisse.isEmpty)
        #expect(viewModel.suchbegriff.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
        #expect(viewModel.angezeigteStädte.isEmpty)
    }

    // MARK: - alleStaedteLaden

    @Test("alleStaedteLaden populates alleStaedte from service")
    func alleStaedteLadenPopulatesList() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testCities()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.alleStaedte.count == 3)
    }

    @Test("alleStaedteLaden also populates suchergebnisse initially")
    func alleStaedteLadenPopulatesSearchResults() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testCities()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.suchergebnisse.count == 3)
    }

    @Test("alleStaedteLaden calls alleCities exactly once")
    func alleStaedteLadenCallsServiceOnce() async {
        let (viewModel, service) = makeSUT()
        await viewModel.alleStaedteLaden()
        #expect(service.alleCitiesAufrufe == 1)
    }

    @Test("alleStaedteLaden with empty service results in empty list")
    func alleStaedteLadenWithEmptyServiceResultsInEmptyList() async {
        let (viewModel, _) = makeSUT()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.alleStaedte.isEmpty)
    }

    // MARK: - angezeigteStädte (Displayed Cities)

    @Test("angezeigteStädte returns alleStaedte when no search term is set")
    func angezeigteStädteReturnsAllCitiesWithoutSearchTerm() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testCities()
        await viewModel.alleStaedteLaden()
        #expect(viewModel.angezeigteStädte.count == 3)
    }

    @Test("angezeigteStädte returns suchergebnisse when search term is set")
    func angezeigteStädteReturnsSearchResultsWithTerm() async {
        let (viewModel, service) = makeSUT()
        service.verfügbareCities = testCities()
        service.suchenResult = [testCities()[0]] // Berlin only
        await viewModel.alleStaedteLaden()
        viewModel.suchbegriff = "Berlin"
        await viewModel.suchen()
        #expect(viewModel.angezeigteStädte.count == 1)
        #expect(viewModel.angezeigteStädte.first?.name == "Berlin")
    }

    @Test("angezeigteStädte is empty when search returns no results")
    func angezeigteStädteIsEmptyWithNoResults() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = []
        viewModel.suchbegriff = "ZZZ"
        await viewModel.suchen()
        #expect(viewModel.angezeigteStädte.isEmpty)
    }

    // MARK: - suchen

    @Test("suchen updates suchergebnisse")
    func suchenUpdatesSuchErgebnisse() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = [testCities()[2]] // Paris only
        viewModel.suchbegriff = "Paris"
        await viewModel.suchen()
        #expect(viewModel.suchergebnisse.count == 1)
        #expect(viewModel.suchergebnisse.first?.name == "Paris")
    }

    @Test("suchen sets isLoading to false after completion")
    func suchenSetsIsLoadingFalseAfterCompletion() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = []
        await viewModel.suchen()
        #expect(viewModel.isLoading == false)
    }

    @Test("suchen passes current suchbegriff to service")
    func suchenPassesSearchTermToService() async {
        let (viewModel, service) = makeSUT()
        viewModel.suchbegriff = "Munich"
        await viewModel.suchen()
        #expect(service.suchenAufrufe.last == "Munich")
    }

    @Test("suchen with empty search term passes empty string to service")
    func suchenWithEmptyTermPassesEmptyStringToService() async {
        let (viewModel, service) = makeSUT()
        viewModel.suchbegriff = ""
        await viewModel.suchen()
        #expect(service.suchenAufrufe.last == "")
    }

    @Test("suchen sets fehlerMeldung to nil on success")
    func suchenSetsErrorNilOnSuccess() async {
        let (viewModel, service) = makeSUT()
        service.suchenResult = []
        await viewModel.suchen()
        #expect(viewModel.fehlerMeldung == nil)
    }

    // MARK: - fehlerZurücksetzen (Reset Error)

    @Test("fehlerZurücksetzen removes fehlerMeldung")
    func fehlerZurücksetzenRemovesErrorMessage() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerMeldung = "Testfehler"
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }

    @Test("fehlerZurücksetzen with nil error is safe")
    func fehlerZurücksetzenWithNilErrorIsSafe() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
    }

    // MARK: - hatFehler

    @Test("hatFehler is true when fehlerMeldung is not nil")
    func hatFehlerIsTrueWhenErrorIsSet() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerMeldung = "Fehler"
        #expect(viewModel.hatFehler == true)
    }

    @Test("hatFehler is false when fehlerMeldung is nil")
    func hatFehlerIsFalseWhenErrorIsNil() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.hatFehler == false)
    }
}

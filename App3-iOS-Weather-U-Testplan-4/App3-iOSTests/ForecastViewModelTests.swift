// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests for `ForecastViewModel`.
/// Verifies loading state, correct forecast data, and error handling.
@MainActor
struct ForecastViewModelTests {

    /// Creates the system under test together with its injected mock service.
    /// - Returns: A tuple of the configured `ForecastViewModel` and its `MockWeatherService`.
    private func makeSUT() -> (viewModel: ForecastViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        let viewModel = ForecastViewModel(service: service)
        return (viewModel, service)
    }

    /// Creates a minimal test city near Munich coordinates.
    private func testCity() -> City {
        City(name: "Vorhersagestadt", land: "Testland", latitude: 48.0, longitude: 11.0)
    }

    /// Creates a `WeeklyForecast` with the given number of daily entries.
    /// Min/max temperatures increase by 1 °C per day starting at 10/20 °C.
    /// - Parameter dayCount: Number of daily entries; defaults to 7.
    private func testForecast(dayCount: Int = 7) -> WeeklyForecast {
        let basis = Date()
        let days = (0..<dayCount).map { offset in
            DailyForecast(
                datum: basis.addingTimeInterval(Double(offset) * 86_400),
                minTemperatur: Double(offset) + 10,
                maxTemperatur: Double(offset) + 20,
                bedingung: .sonnig,
                regenWahrscheinlichkeit: 10,
                luftfeuchtigkeit: 50
            )
        }
        return WeeklyForecast(city: testCity(), vorhersagen: days)
    }

    // MARK: - Initial State

    @Test("ViewModel has correct initial state")
    func viewModelHasCorrectInitialState() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.wochenvorhersage == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
        #expect(viewModel.vorhersagen.isEmpty)
    }

    // MARK: - vorhersageLaden (happy path)

    @Test("vorhersageLaden sets wochenvorhersage on success")
    func vorhersageLadenSetsWeeklyForecastOnSuccess() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testForecast()
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.wochenvorhersage != nil)
    }

    @Test("vorhersageLaden: vorhersagen contains seven days")
    func vorhersageLadenForecastsContainSevenDays() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testForecast()
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.vorhersagen.count == 7)
    }

    @Test("vorhersageLaden sets isLoading to false after completion")
    func vorhersageLadenSetsIsLoadingFalseAfterCompletion() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testForecast()
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.isLoading == false)
    }

    @Test("vorhersageLaden sets fehlerMeldung to nil on success")
    func vorhersageLadenSetsErrorNilOnSuccess() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testForecast()
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.fehlerMeldung == nil)
    }

    @Test("vorhersagen is empty when no forecast has been loaded yet")
    func vorhersagenIsEmptyWithoutLoadedData() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.vorhersagen.isEmpty)
    }

    @Test("vorhersageLaden passes the correct city to the service")
    func vorhersageLadenPassesCorrectCityToService() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testForecast()
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(service.wochenvorhersageAufrufe.first?.name == "Vorhersagestadt")
    }

    @Test("vorhersagen contains correct temperature data")
    func vorhersagenContainsCorrectTemperatureData() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageResult = testForecast()
        await viewModel.vorhersageLaden(fuer: testCity())
        let first = viewModel.vorhersagen.first
        #expect(first?.minTemperatur == 10.0)
        #expect(first?.maxTemperatur == 20.0)
    }

    // MARK: - vorhersageLaden (error paths)

    @Test("vorhersageLaden sets fehlerMeldung on stadtNichtGefunden")
    func vorhersageLadenSetsErrorOnCityNotFound() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.fehlerMeldung != nil)
    }

    @Test("vorhersageLaden sets fehlerMeldung on datenNichtVerfügbar")
    func vorhersageLadenSetsErrorOnDataUnavailable() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .datenNichtVerfügbar
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.fehlerMeldung != nil)
    }

    @Test("hatFehler is true when fehlerMeldung is set")
    func hatFehlerIsTrueWhenErrorIsSet() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.hatFehler == true)
    }

    @Test("vorhersageLaden sets isLoading to false after error")
    func vorhersageLadenSetsIsLoadingFalseAfterError() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.isLoading == false)
    }

    @Test("vorhersagen is empty when an error occurred")
    func vorhersagenIsEmptyOnLoadError() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .datenNichtVerfügbar
        await viewModel.vorhersageLaden(fuer: testCity())
        #expect(viewModel.vorhersagen.isEmpty)
    }

    // MARK: - fehlerZurücksetzen (Reset Error)

    @Test("fehlerZurücksetzen clears fehlerMeldung")
    func fehlerZurücksetzenClearsErrorMessage() async {
        let (viewModel, service) = makeSUT()
        service.wochenvorhersageFehler = .stadtNichtGefunden
        await viewModel.vorhersageLaden(fuer: testCity())
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }
}

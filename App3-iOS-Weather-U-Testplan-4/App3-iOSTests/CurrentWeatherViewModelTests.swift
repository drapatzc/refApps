// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests for `CurrentWeatherViewModel`.
/// Verifies loading state, successful data fetch, and error handling.
@MainActor
struct CurrentWeatherViewModelTests {

    /// Creates the system under test together with its injected mock service.
    /// - Returns: A tuple of the configured `CurrentWeatherViewModel` and its `MockWeatherService`.
    private func makeSUT() -> (viewModel: CurrentWeatherViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        let viewModel = CurrentWeatherViewModel(service: service)
        return (viewModel, service)
    }

    /// Creates a minimal test city near Munich coordinates.
    private func testCity() -> City {
        City(name: "Teststadt", land: "Testland", latitude: 48.0, longitude: 11.0)
    }

    /// Creates a valid `CurrentWeather` snapshot with fixed values for assertion.
    private func testWeather() -> CurrentWeather {
        let basis = Date()
        return CurrentWeather(
            city: testCity(),
            temperatur: 22.0,
            gefuehlteTemperatur: 21.0,
            luftfeuchtigkeit: 55,
            windgeschwindigkeit: 12.0,
            windrichtung: "NW",
            sichtweite: 18.0,
            uvIndex: 5,
            bedingung: .sonnig,
            sonnenaufgang: basis,
            sonnenuntergang: basis.addingTimeInterval(50_000)
        )
    }

    // MARK: - Initial State

    @Test("ViewModel has correct initial state")
    func viewModelHasCorrectInitialState() {
        let (viewModel, _) = makeSUT()
        #expect(viewModel.aktuellesWetter == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }

    // MARK: - wetterLaden (happy path)

    @Test("wetterLaden sets aktuellesWetter after successful fetch")
    func wetterLadenSetsCurrentWeatherOnSuccess() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWeather()
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.aktuellesWetter != nil)
        #expect(viewModel.aktuellesWetter?.temperatur == 22.0)
    }

    @Test("wetterLaden sets isLoading to false after completion")
    func wetterLadenSetsIsLoadingFalseAfterCompletion() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWeather()
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.isLoading == false)
    }

    @Test("wetterLaden sets fehlerMeldung to nil on success")
    func wetterLadenSetsErrorNilOnSuccess() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWeather()
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.fehlerMeldung == nil)
    }

    @Test("wetterLaden passes the correct city to the service")
    func wetterLadenPassesCorrectCityToService() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWeather()
        let city = testCity()
        await viewModel.wetterLaden(fuer: city)
        #expect(service.aktuellesWetterAufrufe.first?.name == "Teststadt")
    }

    @Test("wetterLaden sets weather condition correctly")
    func wetterLadenSetsWeatherConditionCorrectly() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWeather()
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.aktuellesWetter?.bedingung == .sonnig)
    }

    @Test("hatFehler is false after successful load")
    func hatFehlerIsFalseAfterSuccess() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterResult = testWeather()
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.hatFehler == false)
    }

    // MARK: - wetterLaden (error paths)

    @Test("wetterLaden sets fehlerMeldung on stadtNichtGefunden")
    func wetterLadenSetsErrorOnCityNotFound() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.fehlerMeldung != nil)
        #expect(viewModel.fehlerMeldung?.isEmpty == false)
    }

    @Test("wetterLaden sets fehlerMeldung on datenNichtVerfügbar")
    func wetterLadenSetsErrorOnDataUnavailable() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .datenNichtVerfügbar
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.fehlerMeldung != nil)
    }

    @Test("hatFehler is true when fehlerMeldung is set")
    func hatFehlerIsTrueWhenErrorIsSet() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.hatFehler == true)
    }

    @Test("wetterLaden sets isLoading to false after error")
    func wetterLadenSetsIsLoadingFalseAfterError() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.isLoading == false)
    }

    @Test("aktuellesWetter remains nil on error")
    func aktuellesWetterRemainsNilOnError() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testCity())
        #expect(viewModel.aktuellesWetter == nil)
    }

    // MARK: - fehlerZurücksetzen (Reset Error)

    @Test("fehlerZurücksetzen clears fehlerMeldung")
    func fehlerZurücksetzenClearsErrorMessage() async {
        let (viewModel, service) = makeSUT()
        service.aktuellesWetterFehler = .stadtNichtGefunden
        await viewModel.wetterLaden(fuer: testCity())
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
        #expect(viewModel.hatFehler == false)
    }

    @Test("fehlerZurücksetzen is idempotent when fehlerMeldung is already nil")
    func fehlerZurücksetzenIsIdempotentWhenAlreadyNil() {
        let (viewModel, _) = makeSUT()
        viewModel.fehlerZurücksetzen()
        #expect(viewModel.fehlerMeldung == nil)
    }
}

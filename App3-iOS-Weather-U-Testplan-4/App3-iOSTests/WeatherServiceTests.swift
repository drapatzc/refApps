// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests for `WeatherService`.
/// Verifies delegation to the repository and validation logic.
struct WeatherServiceTests {

    /// Creates the system under test together with its injected mock repository.
    /// - Returns: A tuple of the configured `WeatherService` and its `MockWeatherRepository`.
    private func makeSUT() -> (service: WeatherService, repository: MockWeatherRepository) {
        let repository = MockWeatherRepository()
        let service = WeatherService(repository: repository)
        return (service, repository)
    }

    /// Creates a minimal test city with zero coordinates.
    private func testCity() -> City {
        City(name: "Teststadt", land: "Testland", latitude: 0, longitude: 0)
    }

    /// Creates a valid `CurrentWeather` snapshot for the given city (or a default test city).
    /// - Parameter city: City to attach to the snapshot; defaults to `testCity()`.
    private func testWeather(for city: City? = nil) -> CurrentWeather {
        let stadt = city ?? City(name: "Teststadt", land: "Testland", latitude: 0, longitude: 0)
        let basis = Date()
        return CurrentWeather(
            city: stadt,
            temperatur: 20.0,
            gefuehlteTemperatur: 19.0,
            luftfeuchtigkeit: 60,
            windgeschwindigkeit: 10.0,
            windrichtung: "W",
            sichtweite: 15.0,
            uvIndex: 4,
            bedingung: .sonnig,
            sonnenaufgang: basis,
            sonnenuntergang: basis.addingTimeInterval(50_000)
        )
    }

    /// Creates a valid 7-day `WeeklyForecast` for the given city (or a default test city).
    /// Each day is offset by one day from the base date with fixed temperature values.
    /// - Parameter city: City to attach to the forecast; defaults to `testCity()`.
    private func testForecast(for city: City? = nil) -> WeeklyForecast {
        let stadt = city ?? testCity()
        let basis = Date()
        let days = (0..<7).map { offset in
            DailyForecast(
                datum: basis.addingTimeInterval(Double(offset) * 86_400),
                minTemperatur: 10,
                maxTemperatur: 20,
                bedingung: .sonnig,
                regenWahrscheinlichkeit: 10,
                luftfeuchtigkeit: 50
            )
        }
        return WeeklyForecast(city: stadt, vorhersagen: days)
    }

    // MARK: - alleCities

    @Test("alleCities delegates to the repository")
    func alleCitiesDelegatestoRepository() {
        let (service, repository) = makeSUT()
        repository.gespeicherteCities = [testCity()]
        let result = service.alleCities()
        #expect(result.count == 1)
        #expect(repository.alleCitiesAufrufe == 1)
    }

    @Test("alleCities returns empty list when repository is empty")
    func alleCitiesReturnsEmptyListForEmptyRepository() {
        let (service, _) = makeSUT()
        #expect(service.alleCities().isEmpty)
    }

    @Test("alleCities returns multiple cities correctly")
    func alleCitiesReturnsMultipleCitiesCorrectly() {
        let (service, repository) = makeSUT()
        let cities = [testCity(), City(name: "B", land: "L", latitude: 1, longitude: 1)]
        repository.gespeicherteCities = cities
        #expect(service.alleCities().count == 2)
    }

    // MARK: - aktuellesWetter (happy path)

    @Test("aktuellesWetter delegates the fetch to the repository")
    func aktuellesWetterDelegatesToRepository() async throws {
        let (service, repository) = makeSUT()
        let city = testCity()
        repository.aktuellesWetterResult = testWeather(for: city)
        _ = try await service.aktuellesWetter(fuer: city)
        #expect(repository.aktuellesWetterAufrufe.count == 1)
        #expect(repository.aktuellesWetterAufrufe.first?.name == "Teststadt")
    }

    @Test("aktuellesWetter returns the correct weather object")
    func aktuellesWetterReturnsCorrectWeatherObject() async throws {
        let (service, repository) = makeSUT()
        let expected = testWeather()
        repository.aktuellesWetterResult = expected
        let result = try await service.aktuellesWetter(fuer: testCity())
        #expect(result.temperatur == 20.0)
        #expect(result.bedingung == .sonnig)
    }

    // MARK: - aktuellesWetter (error paths)

    @Test("aktuellesWetter forwards stadtNichtGefunden error")
    func aktuellesWetterForwardsCityNotFoundError() async {
        let (service, repository) = makeSUT()
        repository.aktuellesWetterFehler = .stadtNichtGefunden
        await #expect(throws: WetterFehler.stadtNichtGefunden) {
            try await service.aktuellesWetter(fuer: testCity())
        }
    }

    @Test("aktuellesWetter forwards datenNichtVerfügbar error")
    func aktuellesWetterForwardsDataUnavailableError() async {
        let (service, repository) = makeSUT()
        repository.aktuellesWetterFehler = .datenNichtVerfügbar
        await #expect(throws: WetterFehler.datenNichtVerfügbar) {
            try await service.aktuellesWetter(fuer: testCity())
        }
    }

    // MARK: - wochenvorhersage (happy path)

    @Test("wochenvorhersage delegates the fetch to the repository")
    func wochenvorhersageDelegatesToRepository() async throws {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageResult = testForecast()
        _ = try await service.wochenvorhersage(fuer: testCity())
        #expect(repository.wochenvorhersageAufrufe.count == 1)
    }

    @Test("wochenvorhersage returns seven days")
    func wochenvorhersageReturnsSevenDays() async throws {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageResult = testForecast()
        let result = try await service.wochenvorhersage(fuer: testCity())
        #expect(result.vorhersagen.count == 7)
    }

    // MARK: - wochenvorhersage (error paths)

    @Test("wochenvorhersage forwards stadtNichtGefunden error")
    func wochenvorhersageForwardsCityNotFoundError() async {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageFehler = .stadtNichtGefunden
        await #expect(throws: WetterFehler.stadtNichtGefunden) {
            try await service.wochenvorhersage(fuer: testCity())
        }
    }

    @Test("wochenvorhersage forwards datenNichtVerfügbar error")
    func wochenvorhersageForwardsDataUnavailableError() async {
        let (service, repository) = makeSUT()
        repository.wochenvorhersageFehler = .datenNichtVerfügbar
        await #expect(throws: WetterFehler.datenNichtVerfügbar) {
            try await service.wochenvorhersage(fuer: testCity())
        }
    }

    // MARK: - citiesSuchen

    @Test("citiesSuchen delegates trimmed search term to repository")
    func citiesSuchenDelegatesTrimmedTerm() async {
        let (service, repository) = makeSUT()
        repository.gespeicherteCities = [testCity()]
        _ = await service.citiesSuchen(suchbegriff: "  Test  ")
        #expect(repository.citiesSuchenAufrufe.first == "Test")
    }

    @Test("citiesSuchen with empty term returns all cities")
    func citiesSuchenWithEmptyTermReturnsAllCities() async {
        let (service, repository) = makeSUT()
        let cities = [testCity(), City(name: "B", land: "L", latitude: 0, longitude: 0)]
        repository.gespeicherteCities = cities
        let result = await service.citiesSuchen(suchbegriff: "")
        #expect(result.count == 2)
    }

    @Test("citiesSuchen with whitespace-only term trims to empty search")
    func citiesSuchenWithWhitespaceOnlyTermIsTrimmmed() async {
        let (service, repository) = makeSUT()
        _ = await service.citiesSuchen(suchbegriff: "   ")
        #expect(repository.citiesSuchenAufrufe.first == "")
    }
}

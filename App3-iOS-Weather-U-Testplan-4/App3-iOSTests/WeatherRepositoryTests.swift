// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Testing
import Foundation
@testable import App3_iOS

/// Tests for `WeatherSampleRepository`.
/// Verifies both the happy paths (correct returns) and error cases.
struct WeatherRepositoryTests {

    /// Creates a fresh `WeatherSampleRepository` as the system under test.
    private func makeSUT() -> WeatherSampleRepository {
        WeatherSampleRepository()
    }

    /// Creates a known Berlin test city (ID from the repository).
    private func berlin() -> City {
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000001")!,
             name: "Berlin", land: "Germany", latitude: 52.52, longitude: 13.40)
    }

    /// Creates an unknown city that does not exist in the repository.
    private func unknownCity() -> City {
        City(name: "Nirgendwo", land: "Unbekannt", latitude: 0, longitude: 0)
    }

    // MARK: - alleCities

    @Test("alleCities returns exactly ten cities")
    func alleCitiesReturnsTenCities() {
        let sut = makeSUT()
        #expect(sut.alleCities().count == 10)
    }

    @Test("alleCities contains Berlin")
    func alleCitiesContainsBerlin() {
        let sut = makeSUT()
        #expect(sut.alleCities().contains { $0.name == "Berlin" })
    }

    @Test("alleCities contains Munich")
    func alleCitiesContainsMunich() {
        let sut = makeSUT()
        #expect(sut.alleCities().contains { $0.name == "Munich" })
    }

    @Test("alleCities contains no duplicates (unique IDs)")
    func alleCitiesContainsNoDuplicateIDs() {
        let sut = makeSUT()
        let ids = sut.alleCities().map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("alleCities contains no empty names")
    func alleCitiesContainsNoEmptyNames() {
        let sut = makeSUT()
        #expect(sut.alleCities().allSatisfy { !$0.name.isEmpty })
    }

    // MARK: - aktuellesWetter (happy path)

    @Test("aktuellesWetter returns weather for Berlin")
    func aktuellesWetterReturnsWeatherForBerlin() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.city.name == "Berlin")
    }

    @Test("aktuellesWetter: temperature is in plausible range (-30 to 50 °C)")
    func aktuellesWetterTemperatureInPlausibleRange() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.temperatur >= -30 && wetter.temperatur <= 50)
    }

    @Test("aktuellesWetter: feels-like temperature is in plausible range")
    func aktuellesWetterFeelsLikeTemperatureInPlausibleRange() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.gefuehlteTemperatur >= -40 && wetter.gefuehlteTemperatur <= 55)
    }

    @Test("aktuellesWetter: humidity is between 0 and 100 percent")
    func aktuellesWetterHumidityInValidRange() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.luftfeuchtigkeit >= 0 && wetter.luftfeuchtigkeit <= 100)
    }

    @Test("aktuellesWetter: wind speed is not negative")
    func aktuellesWetterWindSpeedNotNegative() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.windgeschwindigkeit >= 0)
    }

    @Test("aktuellesWetter: visibility is positive")
    func aktuellesWetterVisibilityIsPositive() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.sichtweite > 0)
    }

    @Test("aktuellesWetter: UV index is between 0 and 11")
    func aktuellesWetterUvIndexInValidRange() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.uvIndex >= 0 && wetter.uvIndex <= 11)
    }

    @Test("aktuellesWetter: wind direction is not empty")
    func aktuellesWetterWindDirectionNotEmpty() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(!wetter.windrichtung.isEmpty)
    }

    @Test("aktuellesWetter: sunrise is before sunset")
    func aktuellesWetterSunriseBeforeSunset() throws {
        let sut = makeSUT()
        let wetter = try sut.aktuellesWetter(fuer: berlin())
        #expect(wetter.sonnenaufgang < wetter.sonnenuntergang)
    }

    @Test("aktuellesWetter returns deterministic result for the same city")
    func aktuellesWetterIsDeterministic() throws {
        let sut = makeSUT()
        let firstQuery = try sut.aktuellesWetter(fuer: berlin())
        let secondQuery = try sut.aktuellesWetter(fuer: berlin())
        #expect(firstQuery.temperatur == secondQuery.temperatur)
        #expect(firstQuery.bedingung == secondQuery.bedingung)
    }

    // MARK: - aktuellesWetter (error paths)

    @Test("aktuellesWetter throws stadtNichtGefunden for unknown city")
    func aktuellesWetterThrowsErrorForUnknownCity() {
        let sut = makeSUT()
        #expect(throws: WetterFehler.stadtNichtGefunden) {
            try sut.aktuellesWetter(fuer: unknownCity())
        }
    }

    @Test("aktuellesWetter throws error when city ID does not exist")
    func aktuellesWetterThrowsErrorForUnknownID() {
        let sut = makeSUT()
        let foreignCity = City(id: UUID(), name: "Berlin", land: "Germany", latitude: 52.52, longitude: 13.40)
        #expect(throws: WetterFehler.stadtNichtGefunden) {
            try sut.aktuellesWetter(fuer: foreignCity)
        }
    }

    // MARK: - wochenvorhersage (happy path)

    @Test("wochenvorhersage returns seven daily forecasts")
    func wochenvorhersageReturnsSevenDays() throws {
        let sut = makeSUT()
        let forecast = try sut.wochenvorhersage(fuer: berlin())
        #expect(forecast.vorhersagen.count == 7)
    }

    @Test("wochenvorhersage: min temperature <= max temperature on each day")
    func wochenvorhersageMinTempLessOrEqualMaxTemp() throws {
        let sut = makeSUT()
        let forecast = try sut.wochenvorhersage(fuer: berlin())
        #expect(forecast.vorhersagen.allSatisfy { $0.minTemperatur <= $0.maxTemperatur })
    }

    @Test("wochenvorhersage: rain probability between 0 and 100")
    func wochenvorhersageRainProbabilityInValidRange() throws {
        let sut = makeSUT()
        let forecast = try sut.wochenvorhersage(fuer: berlin())
        #expect(forecast.vorhersagen.allSatisfy {
            $0.regenWahrscheinlichkeit >= 0 && $0.regenWahrscheinlichkeit <= 100
        })
    }

    @Test("wochenvorhersage: humidity of all days between 0 and 100")
    func wochenvorhersageHumidityOfAllDaysValid() throws {
        let sut = makeSUT()
        let forecast = try sut.wochenvorhersage(fuer: berlin())
        #expect(forecast.vorhersagen.allSatisfy {
            $0.luftfeuchtigkeit >= 0 && $0.luftfeuchtigkeit <= 100
        })
    }

    @Test("wochenvorhersage: data belongs to the requested city")
    func wochenvorhersageBelongsToRequestedCity() throws {
        let sut = makeSUT()
        let forecast = try sut.wochenvorhersage(fuer: berlin())
        #expect(forecast.city.name == "Berlin")
    }

    // MARK: - wochenvorhersage (error paths)

    @Test("wochenvorhersage throws stadtNichtGefunden for unknown city")
    func wochenvorhersageThrowsErrorForUnknownCity() {
        let sut = makeSUT()
        #expect(throws: WetterFehler.stadtNichtGefunden) {
            try sut.wochenvorhersage(fuer: unknownCity())
        }
    }

    // MARK: - citiesSuchen (happy path)

    @Test("citiesSuchen with empty term returns all cities")
    func citiesSuchenWithEmptyTermReturnsAllCities() {
        let sut = makeSUT()
        #expect(sut.citiesSuchen(suchbegriff: "").count == 10)
    }

    @Test("citiesSuchen finds Berlin by name")
    func citiesSuchenFindsBerlinByName() {
        let sut = makeSUT()
        let result = sut.citiesSuchen(suchbegriff: "Berlin")
        #expect(result.count == 1)
        #expect(result.first?.name == "Berlin")
    }

    @Test("citiesSuchen finds German cities by country name")
    func citiesSuchenFindsCitiesByCountry() {
        let sut = makeSUT()
        let result = sut.citiesSuchen(suchbegriff: "Germany")
        #expect(result.count == 3) // Berlin, Munich, Hamburg
    }

    @Test("citiesSuchen is case-insensitive")
    func citiesSuchenIsCaseInsensitive() {
        let sut = makeSUT()
        let upper = sut.citiesSuchen(suchbegriff: "BERLIN")
        let lower = sut.citiesSuchen(suchbegriff: "berlin")
        #expect(upper.count == lower.count)
        #expect(upper.first?.name == lower.first?.name)
    }

    @Test("citiesSuchen with whitespace-only term returns all cities")
    func citiesSuchenWithWhitespaceOnlyReturnsAllCities() {
        let sut = makeSUT()
        #expect(sut.citiesSuchen(suchbegriff: "   ").count == 10)
    }

    // MARK: - citiesSuchen (error paths)

    @Test("citiesSuchen returns empty list for non-existent city")
    func citiesSuchenReturnsEmptyListForNonExistentCity() {
        let sut = makeSUT()
        let result = sut.citiesSuchen(suchbegriff: "ZZZNichtVorhandenXXX")
        #expect(result.isEmpty)
    }
}

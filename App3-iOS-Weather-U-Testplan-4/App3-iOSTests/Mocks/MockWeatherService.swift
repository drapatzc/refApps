// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation
@testable import App3_iOS

/// Test double for `WeatherServiceProtocol`.
/// Records all method calls and returns configurable test values.
final class MockWeatherService: WeatherServiceProtocol {

    // MARK: - Configurable Return Values

    /// Cities returned by `alleCities()`.
    var verfügbareCities: [City] = []
    /// If set, `aktuellesWetter(fuer:)` throws this error.
    var aktuellesWetterFehler: WetterFehler?
    /// If set, `wochenvorhersage(fuer:)` throws this error.
    var wochenvorhersageFehler: WetterFehler?
    /// Return value for `aktuellesWetter(fuer:)`.
    var aktuellesWetterResult: CurrentWeather?
    /// Return value for `wochenvorhersage(fuer:)`.
    var wochenvorhersageResult: WeeklyForecast?
    /// Return value for `citiesSuchen(suchbegriff:)`; `nil` → returns `verfügbareCities`.
    var suchenResult: [City]?

    // MARK: - Call Recording

    /// Number of `alleCities()` calls.
    var alleCitiesAufrufe: Int = 0
    /// Cities for which `aktuellesWetter(fuer:)` was called.
    var aktuellesWetterAufrufe: [City] = []
    /// Cities for which `wochenvorhersage(fuer:)` was called.
    var wochenvorhersageAufrufe: [City] = []
    /// Search terms passed to `citiesSuchen(suchbegriff:)`.
    var suchenAufrufe: [String] = []

    // MARK: - WeatherServiceProtocol

    func alleCities() -> [City] {
        alleCitiesAufrufe += 1
        return verfügbareCities
    }

    func aktuellesWetter(fuer city: City) async throws -> CurrentWeather {
        aktuellesWetterAufrufe.append(city)
        if let fehler = aktuellesWetterFehler { throw fehler }
        guard let result = aktuellesWetterResult else {
            throw WetterFehler.stadtNichtGefunden
        }
        return result
    }

    func wochenvorhersage(fuer city: City) async throws -> WeeklyForecast {
        wochenvorhersageAufrufe.append(city)
        if let fehler = wochenvorhersageFehler { throw fehler }
        guard let result = wochenvorhersageResult else {
            throw WetterFehler.datenNichtVerfügbar
        }
        return result
    }

    func citiesSuchen(suchbegriff: String) async -> [City] {
        suchenAufrufe.append(suchbegriff)
        return suchenResult ?? verfügbareCities
    }
}

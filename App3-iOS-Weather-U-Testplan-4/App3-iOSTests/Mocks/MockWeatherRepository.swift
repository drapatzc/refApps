// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation
@testable import App3_iOS

/// Test double for `WeatherRepositoryProtocol`.
/// Records all method calls and returns configurable test values.
final class MockWeatherRepository: WeatherRepositoryProtocol {

    // MARK: - Configurable Return Values

    /// Cities returned by `alleCities()`.
    var gespeicherteCities: [City] = []
    /// If set, `aktuellesWetter(fuer:)` throws this error.
    var aktuellesWetterFehler: WetterFehler?
    /// If set, `wochenvorhersage(fuer:)` throws this error.
    var wochenvorhersageFehler: WetterFehler?
    /// Return value for `aktuellesWetter(fuer:)`.
    var aktuellesWetterResult: CurrentWeather?
    /// Return value for `wochenvorhersage(fuer:)`.
    var wochenvorhersageResult: WeeklyForecast?

    // MARK: - Call Recording

    /// Number of `alleCities()` calls.
    var alleCitiesAufrufe: Int = 0
    /// Cities for which `aktuellesWetter(fuer:)` was called.
    var aktuellesWetterAufrufe: [City] = []
    /// Cities for which `wochenvorhersage(fuer:)` was called.
    var wochenvorhersageAufrufe: [City] = []
    /// Search terms passed to `citiesSuchen(suchbegriff:)`.
    var citiesSuchenAufrufe: [String] = []

    // MARK: - WeatherRepositoryProtocol

    func alleCities() -> [City] {
        alleCitiesAufrufe += 1
        return gespeicherteCities
    }

    func aktuellesWetter(fuer city: City) throws -> CurrentWeather {
        aktuellesWetterAufrufe.append(city)
        if let fehler = aktuellesWetterFehler { throw fehler }
        guard let result = aktuellesWetterResult else {
            throw WetterFehler.stadtNichtGefunden
        }
        return result
    }

    func wochenvorhersage(fuer city: City) throws -> WeeklyForecast {
        wochenvorhersageAufrufe.append(city)
        if let fehler = wochenvorhersageFehler { throw fehler }
        guard let result = wochenvorhersageResult else {
            throw WetterFehler.datenNichtVerfügbar
        }
        return result
    }

    func citiesSuchen(suchbegriff: String) -> [City] {
        citiesSuchenAufrufe.append(suchbegriff)
        guard !suchbegriff.isEmpty else { return gespeicherteCities }
        return gespeicherteCities.filter {
            $0.name.localizedCaseInsensitiveContains(suchbegriff) ||
            $0.land.localizedCaseInsensitiveContains(suchbegriff)
        }
    }
}

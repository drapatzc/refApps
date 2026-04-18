// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Implementation of the weather repository with hard-coded sample data.
/// Provides realistic, deterministic weather data for ten cities.
/// All values are fixed so tests and previews always receive the same output.
final class WeatherSampleRepository: WeatherRepositoryProtocol {

    // MARK: - City List

    /// Fixed list of ten cities with stable UUIDs and real-world coordinates.
    private let verfügbareCities: [City] = [
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000001")!, name: "Berlin",    land: "Germany",         latitude:  52.52, longitude:  13.40),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000002")!, name: "Munich",    land: "Germany",         latitude:  48.14, longitude:  11.58),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000003")!, name: "Hamburg",   land: "Germany",         latitude:  53.55, longitude:   9.99),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000004")!, name: "Vienna",    land: "Austria",         latitude:  48.21, longitude:  16.37),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000005")!, name: "Zurich",    land: "Switzerland",     latitude:  47.38, longitude:   8.54),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000006")!, name: "Paris",     land: "France",          latitude:  48.86, longitude:   2.35),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000007")!, name: "London",    land: "United Kingdom",  latitude:  51.51, longitude:  -0.13),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000008")!, name: "New York",  land: "USA",             latitude:  40.71, longitude: -74.01),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-000000000009")!, name: "Tokyo",     land: "Japan",           latitude:  35.69, longitude: 139.69),
        City(id: UUID(uuidString: "A3000000-0000-0000-0000-00000000000A")!, name: "Sydney",    land: "Australia",       latitude: -33.87, longitude: 151.21),
    ]

    // MARK: - WeatherRepositoryProtocol

    /// Returns the complete list of available cities.
    func alleCities() -> [City] {
        verfügbareCities
    }

    /// Returns the current weather for a known city.
    /// - Throws: `WetterFehler.stadtNichtGefunden` if `city.id` is not in the repository.
    func aktuellesWetter(fuer city: City) throws -> CurrentWeather {
        guard let index = verfügbareCities.firstIndex(where: { $0.id == city.id }) else {
            throw WetterFehler.stadtNichtGefunden
        }
        return erstelleWetter(fuer: city, index: index)
    }

    /// Returns the 7-day forecast for a known city.
    /// - Throws: `WetterFehler.stadtNichtGefunden` if `city.id` is not in the repository.
    func wochenvorhersage(fuer city: City) throws -> WeeklyForecast {
        guard let index = verfügbareCities.firstIndex(where: { $0.id == city.id }) else {
            throw WetterFehler.stadtNichtGefunden
        }
        return erstelleVorhersage(fuer: city, basisIndex: index)
    }

    /// Searches cities by trimming `suchbegriff` and filtering by name or country
    /// using a case-insensitive, locale-aware comparison.
    /// An empty (or whitespace-only) term returns all cities.
    func citiesSuchen(suchbegriff: String) -> [City] {
        let bereinigt = suchbegriff.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bereinigt.isEmpty else { return verfügbareCities }
        return verfügbareCities.filter {
            $0.name.localizedCaseInsensitiveContains(bereinigt) ||
            $0.land.localizedCaseInsensitiveContains(bereinigt)
        }
    }

    // MARK: - Weather Data (deterministic sample values)

    /// Holds all weather fields for a single city variant.
    private struct WetterVariante {
        /// Temperature in degrees Celsius.
        let temperatur: Double
        /// Feels-like temperature in degrees Celsius.
        let gefuehlteTemperatur: Double
        /// Relative humidity in percent (0–100).
        let luftfeuchtigkeit: Int
        /// Wind speed in km/h.
        let windgeschwindigkeit: Double
        /// Wind direction as a cardinal abbreviation (e.g. "NW").
        let windrichtung: String
        /// Visibility in kilometers.
        let sichtweite: Double
        /// UV index (0–11+).
        let uvIndex: Int
        /// Weather condition for the variant.
        let bedingung: WeatherCondition
    }

    /// Holds all forecast fields for a single day variant.
    private struct VorhersageVariante {
        /// Minimum daily temperature in degrees Celsius.
        let minTemperatur: Double
        /// Maximum daily temperature in degrees Celsius.
        let maxTemperatur: Double
        /// Weather condition for the day.
        let bedingung: WeatherCondition
        /// Probability of rain in percent (0–100).
        let regenWahrscheinlichkeit: Int
        /// Relative humidity in percent (0–100).
        let luftfeuchtigkeit: Int
    }

    /// Ten weather variants – one per city (order matches city list).
    private let wetterVarianten: [WetterVariante] = [
        WetterVariante(temperatur: 18.0, gefuehlteTemperatur: 17.0, luftfeuchtigkeit: 60, windgeschwindigkeit: 14.0, windrichtung: "NW", sichtweite: 18.0, uvIndex: 4, bedingung: .teilbewölkt),
        WetterVariante(temperatur: 24.0, gefuehlteTemperatur: 23.0, luftfeuchtigkeit: 45, windgeschwindigkeit:  8.0, windrichtung:  "S", sichtweite: 25.0, uvIndex: 7, bedingung: .sonnig),
        WetterVariante(temperatur: 14.0, gefuehlteTemperatur: 12.0, luftfeuchtigkeit: 78, windgeschwindigkeit: 22.0, windrichtung:  "W", sichtweite: 10.0, uvIndex: 2, bedingung: .regnerisch),
        WetterVariante(temperatur: 21.0, gefuehlteTemperatur: 20.0, luftfeuchtigkeit: 55, windgeschwindigkeit: 10.0, windrichtung: "NO", sichtweite: 22.0, uvIndex: 6, bedingung: .sonnig),
        WetterVariante(temperatur: 16.0, gefuehlteTemperatur: 15.0, luftfeuchtigkeit: 65, windgeschwindigkeit: 12.0, windrichtung: "NW", sichtweite: 20.0, uvIndex: 5, bedingung: .teilbewölkt),
        WetterVariante(temperatur: 19.0, gefuehlteTemperatur: 18.0, luftfeuchtigkeit: 62, windgeschwindigkeit: 16.0, windrichtung:  "W", sichtweite: 15.0, uvIndex: 4, bedingung: .bewölkt),
        WetterVariante(temperatur: 12.0, gefuehlteTemperatur: 10.0, luftfeuchtigkeit: 82, windgeschwindigkeit: 28.0, windrichtung: "SW", sichtweite:  8.0, uvIndex: 2, bedingung: .starkRegnerisch),
        WetterVariante(temperatur: 22.0, gefuehlteTemperatur: 21.0, luftfeuchtigkeit: 50, windgeschwindigkeit: 18.0, windrichtung:  "N", sichtweite: 20.0, uvIndex: 6, bedingung: .teilbewölkt),
        WetterVariante(temperatur: 28.0, gefuehlteTemperatur: 30.0, luftfeuchtigkeit: 70, windgeschwindigkeit:  5.0, windrichtung: "SO", sichtweite: 12.0, uvIndex: 9, bedingung: .sonnig),
        WetterVariante(temperatur: 20.0, gefuehlteTemperatur: 19.0, luftfeuchtigkeit: 58, windgeschwindigkeit: 10.0, windrichtung: "NW", sichtweite: 25.0, uvIndex: 7, bedingung: .sonnig),
    ]

    /// Seven forecast variants – distributed cyclically over the week.
    private let vorhersageVarianten: [VorhersageVariante] = [
        VorhersageVariante(minTemperatur: 14.0, maxTemperatur: 22.0, bedingung: .sonnig,       regenWahrscheinlichkeit:  5, luftfeuchtigkeit: 48),
        VorhersageVariante(minTemperatur: 11.0, maxTemperatur: 18.0, bedingung: .teilbewölkt,  regenWahrscheinlichkeit: 20, luftfeuchtigkeit: 60),
        VorhersageVariante(minTemperatur:  9.0, maxTemperatur: 14.0, bedingung: .regnerisch,   regenWahrscheinlichkeit: 80, luftfeuchtigkeit: 85),
        VorhersageVariante(minTemperatur:  7.0, maxTemperatur: 13.0, bedingung: .bewölkt,      regenWahrscheinlichkeit: 45, luftfeuchtigkeit: 72),
        VorhersageVariante(minTemperatur: 15.0, maxTemperatur: 24.0, bedingung: .sonnig,       regenWahrscheinlichkeit:  5, luftfeuchtigkeit: 45),
        VorhersageVariante(minTemperatur:  4.0, maxTemperatur:  9.0, bedingung: .schneeig,     regenWahrscheinlichkeit: 70, luftfeuchtigkeit: 90),
        VorhersageVariante(minTemperatur: 12.0, maxTemperatur: 20.0, bedingung: .teilbewölkt,  regenWahrscheinlichkeit: 25, luftfeuchtigkeit: 55),
    ]

    // MARK: - Private Helpers

    /// Builds a `CurrentWeather` instance from the pre-defined variant at position `index`.
    /// Sunrise and sunset times are fixed to 06:30 and 20:15 of the current day.
    /// - Parameters:
    ///   - city: City to associate with the weather snapshot.
    ///   - index: Position in `wetterVarianten`; wrapped with modulo if out of bounds.
    private func erstelleWetter(fuer city: City, index: Int) -> CurrentWeather {
        let variante = wetterVarianten[index % wetterVarianten.count]
        let kalender = Calendar.current
        let heute = Date()
        let sonnenaufgang = kalender.date(bySettingHour: 6, minute: 30, second: 0, of: heute)!
        let sonnenuntergang = kalender.date(bySettingHour: 20, minute: 15, second: 0, of: heute)!

        return CurrentWeather(
            city: city,
            temperatur: variante.temperatur,
            gefuehlteTemperatur: variante.gefuehlteTemperatur,
            luftfeuchtigkeit: variante.luftfeuchtigkeit,
            windgeschwindigkeit: variante.windgeschwindigkeit,
            windrichtung: variante.windrichtung,
            sichtweite: variante.sichtweite,
            uvIndex: variante.uvIndex,
            bedingung: variante.bedingung,
            sonnenaufgang: sonnenaufgang,
            sonnenuntergang: sonnenuntergang
        )
    }

    /// Builds a `WeeklyForecast` with 7 daily entries starting from today.
    /// Each day uses a variant from `vorhersageVarianten`, cycling from `basisIndex`.
    /// - Parameters:
    ///   - city: City to associate with the forecast.
    ///   - basisIndex: Starting offset into `vorhersageVarianten`; cycles with modulo.
    private func erstelleVorhersage(fuer city: City, basisIndex: Int) -> WeeklyForecast {
        let kalender = Calendar.current
        let heute = Date()

        let tagesvorhersagen: [DailyForecast] = (0..<7).map { offset in
            let datum = kalender.date(byAdding: .day, value: offset, to: heute)!
            let varianteIndex = (basisIndex + offset) % vorhersageVarianten.count
            let variante = vorhersageVarianten[varianteIndex]
            return DailyForecast(
                datum: datum,
                minTemperatur: variante.minTemperatur,
                maxTemperatur: variante.maxTemperatur,
                bedingung: variante.bedingung,
                regenWahrscheinlichkeit: variante.regenWahrscheinlichkeit,
                luftfeuchtigkeit: variante.luftfeuchtigkeit
            )
        }

        return WeeklyForecast(city: city, vorhersagen: tagesvorhersagen)
    }
}

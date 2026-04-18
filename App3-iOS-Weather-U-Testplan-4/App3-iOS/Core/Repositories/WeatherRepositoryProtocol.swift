// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Interface for weather data access.
/// Implementations can provide real network sources or test data.
protocol WeatherRepositoryProtocol {
    /// Returns all available cities.
    func alleCities() -> [City]

    /// Loads the current weather for a known city.
    /// - Parameter city: The requested city.
    /// - Throws: `WetterFehler.stadtNichtGefunden` if the city is unknown.
    func aktuellesWetter(fuer city: City) throws -> CurrentWeather

    /// Loads the 7-day forecast for a known city.
    /// - Parameter city: The requested city.
    /// - Throws: `WetterFehler.stadtNichtGefunden` if the city is unknown.
    func wochenvorhersage(fuer city: City) throws -> WeeklyForecast

    /// Searches cities by a search term (name or country).
    /// - Parameter suchbegriff: Search text; an empty string returns all cities.
    func citiesSuchen(suchbegriff: String) -> [City]
}

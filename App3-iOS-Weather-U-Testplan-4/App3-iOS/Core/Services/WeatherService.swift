// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Concrete implementation of the weather service.
/// Delegates data access to the repository and adds input validation
/// (e.g. trimming whitespace from search terms before forwarding).
final class WeatherService: WeatherServiceProtocol {

    /// The underlying data source used for all weather queries.
    private let repository: WeatherRepositoryProtocol

    /// Creates a new `WeatherService` backed by the given repository.
    /// - Parameter repository: Data source that provides weather information.
    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - WeatherServiceProtocol

    /// Returns all available cities by delegating directly to the repository.
    func alleCities() -> [City] {
        repository.alleCities()
    }

    /// Fetches the current weather for `city` by delegating to the repository.
    /// - Throws: `WetterFehler` propagated from the repository.
    func aktuellesWetter(fuer city: City) async throws -> CurrentWeather {
        try repository.aktuellesWetter(fuer: city)
    }

    /// Fetches the 7-day forecast for `city` by delegating to the repository.
    /// - Throws: `WetterFehler` propagated from the repository.
    func wochenvorhersage(fuer city: City) async throws -> WeeklyForecast {
        try repository.wochenvorhersage(fuer: city)
    }

    /// Searches cities by trimming whitespace from `suchbegriff` before
    /// forwarding the sanitised term to the repository.
    func citiesSuchen(suchbegriff: String) async -> [City] {
        let bereinigt = suchbegriff.trimmingCharacters(in: .whitespacesAndNewlines)
        return repository.citiesSuchen(suchbegriff: bereinigt)
    }
}

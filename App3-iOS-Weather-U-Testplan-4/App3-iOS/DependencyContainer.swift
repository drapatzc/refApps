// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Manages all app dependencies (Dependency Injection Container).
/// Provides pre-configured instances of services and repositories.
/// All dependencies are created lazily and shared across the app.
final class DependencyContainer {

    /// Shared singleton instance used throughout the app.
    static let shared = DependencyContainer()

    /// Prevents external instantiation — use `shared` instead.
    private init() {}

    // MARK: - Repositories

    /// The weather data repository. Created once on first access.
    /// Uses `WeatherSampleRepository` as the default implementation.
    private(set) lazy var wetterRepository: WeatherRepositoryProtocol = {
        WeatherSampleRepository()
    }()

    // MARK: - Services

    /// The weather service backed by `wetterRepository`. Created once on first access.
    private(set) lazy var wetterService: WeatherServiceProtocol = {
        WeatherService(repository: wetterRepository)
    }()

    // MARK: - ViewModels

    /// Creates a new `CitySearchViewModel` connected to the shared weather service.
    /// - Returns: A freshly initialised view model ready for city search.
    @MainActor func makeCitySearchViewModel() -> CitySearchViewModel {
        CitySearchViewModel(service: wetterService)
    }

    /// Creates a new `CurrentWeatherViewModel` connected to the shared weather service.
    /// - Returns: A freshly initialised view model ready to load current weather.
    @MainActor func makeCurrentWeatherViewModel() -> CurrentWeatherViewModel {
        CurrentWeatherViewModel(service: wetterService)
    }

    /// Creates a new `ForecastViewModel` connected to the shared weather service.
    /// - Returns: A freshly initialised view model ready to load the 7-day forecast.
    @MainActor func makeForecastViewModel() -> ForecastViewModel {
        ForecastViewModel(service: wetterService)
    }
}

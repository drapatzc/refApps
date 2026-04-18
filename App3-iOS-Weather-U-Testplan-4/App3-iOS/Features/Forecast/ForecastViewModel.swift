// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// ViewModel for the 7-day weather forecast of a city.
@Observable
@MainActor
final class ForecastViewModel {

    /// The weather service used to fetch forecast data.
    private let service: WeatherServiceProtocol

    /// Loaded weekly forecast; `nil` while no data is available yet.
    var wochenvorhersage: WeeklyForecast?
    /// `true` while the forecast is being fetched.
    var isLoading: Bool = false
    /// Error message if the fetch failed; otherwise `nil`.
    var fehlerMeldung: String?

    /// Creates a new `ForecastViewModel`.
    /// - Parameter service: Weather service used to fetch the 7-day forecast.
    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed Properties

    /// Daily forecasts from the loaded weekly forecast, or empty if no data is available.
    var vorhersagen: [DailyForecast] {
        wochenvorhersage?.vorhersagen ?? []
    }

    /// `true` when an error message is present.
    var hatFehler: Bool {
        fehlerMeldung != nil
    }

    // MARK: - Actions

    /// Loads the 7-day forecast for the specified city.
    func vorhersageLaden(fuer city: City) async {
        isLoading = true
        fehlerMeldung = nil
        do {
            wochenvorhersage = try await service.wochenvorhersage(fuer: city)
        } catch let fehler as WetterFehler {
            fehlerMeldung = fehler.localizedDescription
        } catch {
            fehlerMeldung = String(localized: "unknown_error")
        }
        isLoading = false
    }

    /// Resets the current error message.
    func fehlerZurücksetzen() {
        fehlerMeldung = nil
    }
}

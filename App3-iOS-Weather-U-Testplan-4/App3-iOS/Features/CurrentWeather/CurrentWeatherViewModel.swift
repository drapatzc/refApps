// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// ViewModel for displaying the current weather of a city.
@Observable
@MainActor
final class CurrentWeatherViewModel {

    /// The weather service used to fetch current weather data.
    private let service: WeatherServiceProtocol

    /// Loaded weather data; `nil` while no data is available yet.
    var aktuellesWetter: CurrentWeather?
    /// `true` while weather data is being fetched.
    var isLoading: Bool = false
    /// Error message if the fetch failed; otherwise `nil`.
    var fehlerMeldung: String?

    /// Creates a new `CurrentWeatherViewModel`.
    /// - Parameter service: Weather service used to fetch current weather data.
    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed Properties

    /// `true` when an error message is present.
    var hatFehler: Bool {
        fehlerMeldung != nil
    }

    // MARK: - Actions

    /// Loads the current weather for the specified city.
    func wetterLaden(fuer city: City) async {
        isLoading = true
        fehlerMeldung = nil
        do {
            aktuellesWetter = try await service.aktuellesWetter(fuer: city)
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

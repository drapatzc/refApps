// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// ViewModel for city search and selection.
@Observable
@MainActor
final class CitySearchViewModel {

    /// The weather service used to fetch city data.
    private let service: WeatherServiceProtocol

    /// All known cities (loaded initially).
    var alleStaedte: [City] = []
    /// Search results based on the current search term.
    var suchergebnisse: [City] = []
    /// Current search text.
    var suchbegriff: String = ""
    /// Indicates whether a search request is in progress.
    var isLoading: Bool = false
    /// Error message when a problem occurs.
    var fehlerMeldung: String?

    /// Creates a new `CitySearchViewModel`.
    /// - Parameter service: Weather service used to load and search cities.
    init(service: WeatherServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed Properties

    /// Shows search results when a search term is set, otherwise all cities.
    var angezeigteStädte: [City] {
        suchbegriff.isEmpty ? alleStaedte : suchergebnisse
    }

    /// `true` when an error message is present.
    var hatFehler: Bool {
        fehlerMeldung != nil
    }

    // MARK: - Actions

    /// Loads all available cities from the service.
    func alleStaedteLaden() async {
        alleStaedte = service.alleCities()
        suchergebnisse = alleStaedte
    }

    /// Performs a city search with the current `suchbegriff`.
    func suchen() async {
        isLoading = true
        fehlerMeldung = nil
        suchergebnisse = await service.citiesSuchen(suchbegriff: suchbegriff)
        isLoading = false
    }

    /// Resets the current error message.
    func fehlerZurücksetzen() {
        fehlerMeldung = nil
    }
}

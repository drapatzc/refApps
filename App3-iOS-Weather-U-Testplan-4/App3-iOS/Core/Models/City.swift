// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Represents a city with geographic coordinates.
/// Conforms to `Identifiable`, `Equatable`, `Codable`, and `Hashable`
/// so it can be used in SwiftUI lists, navigation, and as a dictionary key.
struct City: Identifiable, Equatable, Codable, Hashable {
    /// Stable unique identifier for the city.
    let id: UUID
    /// Display name of the city (e.g. "Berlin").
    let name: String
    /// Country name in the app's default language (e.g. "Germany").
    let land: String
    /// Geographic latitude in decimal degrees.
    let latitude: Double
    /// Geographic longitude in decimal degrees.
    let longitude: Double

    /// Creates a new `City` instance.
    /// - Parameters:
    ///   - id: Unique identifier; defaults to a new random `UUID`.
    ///   - name: Display name of the city.
    ///   - land: Country name in the app's default language.
    ///   - latitude: Geographic latitude in decimal degrees.
    ///   - longitude: Geographic longitude in decimal degrees.
    init(
        id: UUID = UUID(),
        name: String,
        land: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.land = land
        self.latitude = latitude
        self.longitude = longitude
    }
}

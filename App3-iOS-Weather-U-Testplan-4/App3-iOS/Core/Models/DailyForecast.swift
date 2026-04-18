// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Weather forecast for a single day.
struct DailyForecast: Identifiable, Equatable {
    let id: UUID
    /// Date of the forecast day.
    let datum: Date
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

    /// Creates a new `DailyForecast` instance.
    /// - Parameters:
    ///   - id: Unique identifier; defaults to a new random `UUID`.
    ///   - datum: Date of the forecast day.
    ///   - minTemperatur: Minimum daily temperature in degrees Celsius.
    ///   - maxTemperatur: Maximum daily temperature in degrees Celsius.
    ///   - bedingung: Weather condition for the day.
    ///   - regenWahrscheinlichkeit: Probability of rain in percent (0–100).
    ///   - luftfeuchtigkeit: Relative humidity in percent (0–100).
    init(
        id: UUID = UUID(),
        datum: Date,
        minTemperatur: Double,
        maxTemperatur: Double,
        bedingung: WeatherCondition,
        regenWahrscheinlichkeit: Int,
        luftfeuchtigkeit: Int
    ) {
        self.id = id
        self.datum = datum
        self.minTemperatur = minTemperatur
        self.maxTemperatur = maxTemperatur
        self.bedingung = bedingung
        self.regenWahrscheinlichkeit = regenWahrscheinlichkeit
        self.luftfeuchtigkeit = luftfeuchtigkeit
    }

    /// Full day name localized to the current locale (e.g. "Monday").
    var tagesname: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: datum)
    }

    /// Short date representation localized to the current locale (e.g. "Mon, Apr 10").
    var datumKurz: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, d. MMM"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: datum)
    }
}

// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Current weather for a city at the present moment.
struct CurrentWeather: Equatable {
    let city: City
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
    /// Current weather condition.
    let bedingung: WeatherCondition
    /// Time of sunrise.
    let sonnenaufgang: Date
    /// Time of sunset.
    let sonnenuntergang: Date
    /// Timestamp of the last update.
    let zuletztAktualisiert: Date

    /// Creates a new `CurrentWeather` instance.
    /// - Parameters:
    ///   - city: The city this weather snapshot belongs to.
    ///   - temperatur: Temperature in degrees Celsius.
    ///   - gefuehlteTemperatur: Feels-like temperature in degrees Celsius.
    ///   - luftfeuchtigkeit: Relative humidity in percent (0–100).
    ///   - windgeschwindigkeit: Wind speed in km/h.
    ///   - windrichtung: Wind direction as a cardinal abbreviation (e.g. "NW").
    ///   - sichtweite: Visibility in kilometers.
    ///   - uvIndex: UV index (0–11+).
    ///   - bedingung: Current weather condition.
    ///   - sonnenaufgang: Time of sunrise.
    ///   - sonnenuntergang: Time of sunset.
    ///   - zuletztAktualisiert: Timestamp of the last update; defaults to now.
    init(
        city: City,
        temperatur: Double,
        gefuehlteTemperatur: Double,
        luftfeuchtigkeit: Int,
        windgeschwindigkeit: Double,
        windrichtung: String,
        sichtweite: Double,
        uvIndex: Int,
        bedingung: WeatherCondition,
        sonnenaufgang: Date,
        sonnenuntergang: Date,
        zuletztAktualisiert: Date = Date()
    ) {
        self.city = city
        self.temperatur = temperatur
        self.gefuehlteTemperatur = gefuehlteTemperatur
        self.luftfeuchtigkeit = luftfeuchtigkeit
        self.windgeschwindigkeit = windgeschwindigkeit
        self.windrichtung = windrichtung
        self.sichtweite = sichtweite
        self.uvIndex = uvIndex
        self.bedingung = bedingung
        self.sonnenaufgang = sonnenaufgang
        self.sonnenuntergang = sonnenuntergang
        self.zuletztAktualisiert = zuletztAktualisiert
    }

    /// Formatted temperature display (e.g. "22°").
    var temperaturFormatiert: String {
        String(format: "%.0f°", temperatur)
    }

    /// Formatted feels-like temperature (e.g. "20°").
    var gefuehlteTemperaturFormatiert: String {
        String(format: "%.0f°", gefuehlteTemperatur)
    }
}

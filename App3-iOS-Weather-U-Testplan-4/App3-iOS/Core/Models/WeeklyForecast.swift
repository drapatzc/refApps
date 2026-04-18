// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// 7-day weather forecast for a city.
struct WeeklyForecast: Equatable {
    /// City for which the forecast applies.
    let city: City
    /// Daily forecasts sorted ascending by date.
    let vorhersagen: [DailyForecast]

    /// Creates a new `WeeklyForecast` instance.
    /// - Parameters:
    ///   - city: City the forecast applies to.
    ///   - vorhersagen: Daily forecasts sorted ascending by date (typically 7 entries).
    init(city: City, vorhersagen: [DailyForecast]) {
        self.city = city
        self.vorhersagen = vorhersagen
    }
}

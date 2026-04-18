// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import Foundation

/// Possible weather conditions with SF Symbol and localized description.
enum WeatherCondition: String, CaseIterable, Codable, Equatable {
    case sonnig
    case teilbewölkt
    case bewölkt
    case regnerisch
    case starkRegnerisch
    case gewittig
    case schneeig
    case neblig
    case windig

    /// SF Symbol matching the weather condition.
    var systemSymbol: String {
        switch self {
        case .sonnig:          return "sun.max.fill"
        case .teilbewölkt:     return "cloud.sun.fill"
        case .bewölkt:         return "cloud.fill"
        case .regnerisch:      return "cloud.rain.fill"
        case .starkRegnerisch: return "cloud.heavyrain.fill"
        case .gewittig:        return "cloud.bolt.rain.fill"
        case .schneeig:        return "cloud.snow.fill"
        case .neblig:          return "cloud.fog.fill"
        case .windig:          return "wind"
        }
    }

    /// Localized description of the weather condition.
    var beschreibung: String {
        switch self {
        case .sonnig:          return String(localized: "weather_sunny")
        case .teilbewölkt:     return String(localized: "weather_partly_cloudy")
        case .bewölkt:         return String(localized: "weather_cloudy")
        case .regnerisch:      return String(localized: "weather_rainy")
        case .starkRegnerisch: return String(localized: "weather_heavy_rain")
        case .gewittig:        return String(localized: "weather_thunderstorm")
        case .schneeig:        return String(localized: "weather_snowy")
        case .neblig:          return String(localized: "weather_foggy")
        case .windig:          return String(localized: "weather_windy")
        }
    }
}

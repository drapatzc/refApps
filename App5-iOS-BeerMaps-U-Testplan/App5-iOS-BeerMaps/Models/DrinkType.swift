import Foundation
import SwiftUI

enum DrinkType: String, CaseIterable, Codable {
    case beer = "beer"
    case wine = "wine"
    case cocktail = "cocktail"
    case champagne = "champagne"
    case whiskey = "whiskey"
    case shot = "shot"

    var symbolName: String {
        switch self {
        case .beer: return "mug.fill"
        case .wine: return "wineglass.fill"
        case .cocktail: return "takeoutbag.and.cup.and.straw.fill"
        case .champagne: return "bubbles.and.sparkles"
        case .whiskey: return "drop.fill"
        case .shot: return "cylinder.fill"
        }
    }

    var localizedKey: String {
        switch self {
        case .beer: return "drink_beer"
        case .wine: return "drink_wine"
        case .cocktail: return "drink_cocktail"
        case .champagne: return "drink_champagne"
        case .whiskey: return "drink_whiskey"
        case .shot: return "drink_shot"
        }
    }

    var color: Color {
        switch self {
        case .beer: return .yellow
        case .wine: return .red
        case .cocktail: return .pink
        case .champagne: return .orange
        case .whiskey: return .brown
        case .shot: return .purple
        }
    }
}

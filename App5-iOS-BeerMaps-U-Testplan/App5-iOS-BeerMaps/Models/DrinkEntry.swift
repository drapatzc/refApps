import Foundation
import SwiftData

@Model
final class DrinkEntry {
    @Attribute(.unique) var id: UUID
    var drinkTypeRaw: String
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var username: String?

    init(drinkType: DrinkType, latitude: Double, longitude: Double, username: String? = nil) {
        self.id = UUID()
        self.drinkTypeRaw = drinkType.rawValue
        self.timestamp = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.username = username
    }

    var drinkType: DrinkType {
        DrinkType(rawValue: drinkTypeRaw) ?? .beer
    }
}

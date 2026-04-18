import Foundation
import SwiftData

@Model
final class Person {
    var vorname: String
    var nachname: String
    var erstelltAm: Date

    init(vorname: String, nachname: String) {
        self.vorname = vorname
        self.nachname = nachname
        self.erstelltAm = Date()
    }

    var vollerName: String {
        "\(nachname), \(vorname)"
    }
}

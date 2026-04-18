import Foundation
import SwiftData

struct SampleDataService {

    private static let vornamen = [
        "Anna", "Max", "Lena", "Felix", "Sophie",
        "Lukas", "Emma", "Jonas", "Mia", "Leon",
        "Julia", "Noah", "Marie", "Tim", "Laura",
        "Finn", "Lea", "Ben", "Hannah", "Elias"
    ]

    private static let nachnamen = [
        "Müller", "Schmidt", "Schneider", "Fischer", "Weber",
        "Meyer", "Wagner", "Becker", "Schulz", "Hoffmann",
        "Richter", "Klein", "Wolf", "Schröder", "Neumann",
        "Schwarz", "Zimmermann", "Braun", "Krüger", "Hofmann"
    ]

    /// Legt 100 Beispieleinträge in dem übergebenen ModelContext an.
    static func createSampleData(in context: ModelContext) {
        var count = 0
        outer: for nachname in nachnamen {
            for vorname in vornamen {
                if count >= 100 { break outer }
                context.insert(Person(vorname: vorname, nachname: nachname))
                count += 1
            }
        }
    }
}

import XCTest
@testable import App5_iOS_BeerMaps

final class App5_iOS_BeerMapsTests: XCTestCase {
    func testDrinkEntryInitialization() {
        let entry = DrinkEntry(drinkType: .beer, latitude: 48.1374, longitude: 11.5755, username: "Hopfenkohol")
        XCTAssertEqual(entry.drinkTypeRaw, "beer")
        XCTAssertEqual(entry.drinkType, .beer)
        XCTAssertEqual(entry.latitude, 48.1374, accuracy: 0.0001)
        XCTAssertEqual(entry.longitude, 11.5755, accuracy: 0.0001)
        XCTAssertEqual(entry.username, "Hopfenkohol")
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.timestamp)
    }

    func testDrinkEntryWithoutUsername() {
        let entry = DrinkEntry(drinkType: .wine, latitude: 0, longitude: 0)
        XCTAssertNil(entry.username)
        XCTAssertEqual(entry.drinkType, .wine)
    }

    func testDrinkEntryUniqueIDs() {
        let entry1 = DrinkEntry(drinkType: .beer, latitude: 0, longitude: 0)
        let entry2 = DrinkEntry(drinkType: .beer, latitude: 0, longitude: 0)
        XCTAssertNotEqual(entry1.id, entry2.id)
    }

    func testDrinkTypeRawValues() {
        XCTAssertEqual(DrinkType(rawValue: "beer"), .beer)
        XCTAssertEqual(DrinkType(rawValue: "wine"), .wine)
        XCTAssertNil(DrinkType(rawValue: "invalid"))
    }

    func testDrinkTypeFallbackForInvalidRaw() {
        let entry = DrinkEntry(drinkType: .beer, latitude: 0, longitude: 0)
        entry.drinkTypeRaw = "invalid_type"
        XCTAssertEqual(entry.drinkType, .beer)
    }
}

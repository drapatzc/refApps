import XCTest
import CoreLocation
import SwiftData
@testable import App5_iOS_BeerMaps

@MainActor
final class MapViewModelTests: XCTestCase {
    var sut: MapViewModel!
    var mockLocation: MockLocationService!
    var mockKeychain: MockKeychainService!

    override func setUp() {
        super.setUp()
        mockLocation = MockLocationService()
        mockKeychain = MockKeychainService()
        sut = MapViewModel(locationService: mockLocation, keychainService: mockKeychain)
    }

    func testInitialDrinkIsBeer() {
        XCTAssertEqual(sut.selectedDrink, .beer)
    }

    func testSelectDrink() {
        sut.selectedDrink = .wine
        XCTAssertEqual(sut.selectedDrink, .wine)
    }

    func testRequestLocationWhenNotDetermined() {
        mockLocation.authorizationStatus = .notDetermined
        mockLocation.simulateAuthorizationChange(.notDetermined)
        sut.requestLocationIfNeeded()
        XCTAssertTrue(mockLocation.requestAuthorizationCalled)
    }

    func testShowsDeniedAlertWhenDenied() {
        mockLocation.authorizationStatus = .denied
        mockLocation.simulateAuthorizationChange(.denied)
        sut.requestLocationIfNeeded()
        XCTAssertTrue(sut.showLocationDeniedAlert)
    }

    func testUsernameReturnsFromKeychain() {
        _ = mockKeychain.save(key: KeychainKeys.username, value: "Hopfenkohol")
        XCTAssertEqual(sut.username, "Hopfenkohol")
    }

    func testUsernameGeneratedWhenNotInKeychain() {
        let username = sut.username
        XCTAssertNotNil(username)
        XCTAssertTrue(username!.hasSuffix("kohol"))
    }

    func testDrinkTypeAllCasesExist() {
        XCTAssertEqual(DrinkType.allCases.count, 6)
    }

    func testDrinkTypeSymbolNames() {
        for drink in DrinkType.allCases {
            XCTAssertFalse(drink.symbolName.isEmpty)
        }
    }

    func testDrinkTypeLocalizedKeys() {
        for drink in DrinkType.allCases {
            XCTAssertFalse(drink.localizedKey.isEmpty)
        }
    }
}

import XCTest

/// UI tests covering the BKK Orano v2 Home screen — search-first layout.
final class HomeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchAndLogIn() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()

        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("testmann")
        app.buttons["login_button"].tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        return app
    }

    /// The prominent search field replaces the v1 toolbar-drawer search.
    /// We assert it is visible on launch and accepts input.
    func testHomeSearchFieldIsPresentAndAcceptsInput() throws {
        let app = launchAndLogIn()
        let search = app.textFields["home_search_field"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("Bonus")
        // Typing "Bonus" yields at least one search result row whose label
        // contains "Bonus" (DE or EN fall under the same token).
        let hit = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Bonus'")
        ).firstMatch
        XCTAssertTrue(hit.waitForExistence(timeout: 3))
    }

    /// The status card is the defining element of the v2 dashboard header.
    /// SwiftUI's accessibilityElement(children: .combine) can map to several
    /// element types depending on layout, so we look broadly by identifier.
    func testHomeStatusCardIsVisible() throws {
        let app = launchAndLogIn()
        let status = app.descendants(matching: .any).matching(identifier: "status_card").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5))
    }
}

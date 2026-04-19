import XCTest

/// UI tests covering the profile tab.
final class ProfileUITests: XCTestCase {

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

        // Wait for the tab bar to appear (signifies successful login).
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        return app
    }

    func testProfileTabExposesLogout() throws {
        let app = launchAndLogIn()
        // Navigate to the profile tab (last tab).
        let tabs = app.tabBars.buttons
        let profileTab = tabs.element(boundBy: 3)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 3))
        profileTab.tap()

        // Scroll to bottom to reveal the logout section; the List is
        // long enough on small devices that logout sits below the fold.
        let profileList = app.collectionViews.firstMatch
        if profileList.waitForExistence(timeout: 3) {
            profileList.swipeUp()
            profileList.swipeUp()
        }

        // Logout label varies by locale (Abmelden / Sign out).
        let logoutPredicate = NSPredicate(
            format: "label CONTAINS[c] 'Abmelden' OR label CONTAINS[c] 'Sign out'"
        )
        let anyLogoutElement = app.descendants(matching: .any)
            .matching(logoutPredicate)
            .firstMatch
        XCTAssertTrue(anyLogoutElement.waitForExistence(timeout: 5))
    }

    func testProfileTabOpensAddressEditor() throws {
        let app = launchAndLogIn()
        app.tabBars.buttons.element(boundBy: 3).tap()

        let addressCell = app.cells.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Adresse' OR label CONTAINS[c] 'Address'")
        ).firstMatch
        XCTAssertTrue(addressCell.waitForExistence(timeout: 3))
        addressCell.tap()

        // The address list now shows an add button.
        let addButton = app.buttons["add_address_button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
    }
}

import XCTest

/// UI tests for the profile sheet and its sub-screens in the BKK Atomium app.
///
/// Each test method logs in using a valid demo password, opens the profile sheet,
/// and navigates to the relevant profile destination. `continueAfterFailure` is set
/// to `false` so that the first assertion failure stops the test immediately.
final class ProfileUITests: XCTestCase {

    /// The `XCUIApplication` instance under test.
    var app: XCUIApplication!

    /// Launches the app with `--uitesting` arguments and performs a login before each test.
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        try loginToApp()
    }

    /// Resets the application reference after each test method.
    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Address Tests

    /// Verifies that navigating to the address list shows mock address data loaded from SwiftData.
    func testAddressListIsAccessible() {
        openProfile()
        tapProfileRow(containing: "Adresse", or: "Address")

        // Adressliste sollte geladen sein (Mockdaten vorhanden)
        let address = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Essen' OR label CONTAINS 'Mühlenbach' OR label CONTAINS 'Hauptwohnsitz' OR label CONTAINS 'Primary'")
        ).firstMatch
        XCTAssertTrue(address.waitForExistence(timeout: 5))
    }

    /// Verifies that the email list is accessible and displays at least one email address.
    func testEmailListIsAccessible() {
        openProfile()
        tapProfileRow(containing: "E-Mail", or: "Email")

        let emailEntry = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS '@'")
        ).firstMatch
        XCTAssertTrue(emailEntry.waitForExistence(timeout: 5))
    }

    /// Verifies that the insurance status screen shows the insured person's last name.
    func testInsuranceStatusShowsName() {
        openProfile()
        tapProfileRow(containing: "Versichertenstatus", or: "Insurance Status")

        let name = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Drapatz'")
        ).firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    /// Enters the demo password and taps the login button, then waits for the home screen.
    ///
    /// If the password field is not visible within five seconds the method returns without logging in,
    /// allowing the test to continue if the app is already logged in.
    ///
    /// - Throws: Any error propagated by the XCTest framework.
    private func loginToApp() throws {
        let passwordField = app.secureTextFields["passwordField"]
        guard passwordField.waitForExistence(timeout: 5) else { return }
        passwordField.tap()
        passwordField.typeText("123456")
        app.buttons["loginButton"].tap()

        // Warte bis Home sichtbar ist
        let _ = app.staticTexts["BKK Atomium"].waitForExistence(timeout: 8)
    }

    /// Taps the profile button in the navigation bar to open the profile sheet.
    private func openProfile() {
        let profileButton = app.buttons["profileButton"]
        if profileButton.waitForExistence(timeout: 5) {
            profileButton.tap()
        }
    }

    /// Taps the profile list row whose accessibility label contains either of the two given strings.
    ///
    /// Falls back to searching buttons if no matching cell is found within five seconds.
    ///
    /// - Parameters:
    ///   - german: The German label substring to match (e.g. `"Adresse"`).
    ///   - english: The English label substring to match (e.g. `"Address"`).
    private func tapProfileRow(containing german: String, or english: String) {
        let row = app.cells.matching(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", german, english)
        ).firstMatch

        if row.waitForExistence(timeout: 5) {
            row.tap()
        } else {
            // Fallback: NavigationLink direkt suchen
            let link = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", german, english)
            ).firstMatch
            link.tap()
        }
    }
}

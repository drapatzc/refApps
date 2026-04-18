import XCTest

/// UI tests for the login screen of the BKK Atomium app.
///
/// Each test launches the app with `--uitesting` and `--reset-data` arguments
/// to ensure a clean, predictable environment. `continueAfterFailure` is set to
/// `false` so that the first assertion failure immediately stops the test.
final class LoginUITests: XCTestCase {

    /// The `XCUIApplication` instance under test.
    var app: XCUIApplication!

    /// Launches the app with UI-testing arguments before each test method.
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
    }

    /// Resets the application reference after each test method.
    override func tearDownWithError() throws {
        app = nil
    }

    /// Verifies that the password field is visible on the login screen when the app first launches.
    func testLoginScreenIsDisplayed() {
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
    }

    /// Verifies that tapping the login button with an empty password leaves the user on the login screen.
    ///
    /// The login button should be disabled when the password field is empty, so the user
    /// should remain on the login screen after the tap.
    func testLoginWithEmptyPasswordShowsError() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // Der Button sollte bei leerem Passwort nicht aktiv sein
        // Wir prüfen, dass wir weiterhin auf dem Login-Screen sind
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.exists)
    }

    /// Verifies that entering an incorrect password and tapping login shows an error message.
    func testLoginWithWrongPasswordShowsError() throws {
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))

        passwordField.tap()
        passwordField.typeText("wrongpassword123")

        let loginButton = app.buttons["loginButton"]
        loginButton.tap()

        // Warte auf Fehlermeldung
        let errorText = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'nicht korrekt' OR label CONTAINS[c] 'incorrect'")
        ).firstMatch
        XCTAssertTrue(errorText.waitForExistence(timeout: 5))
    }

    // MARK: - Helper

    /// Types the given password into the password field and taps the login button.
    ///
    /// - Parameter password: The password string to enter.
    /// - Throws: An `XCTSkip` if the password field does not appear within the timeout.
    private func performLogin(password: String) throws {
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText(password)

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.isEnabled)
        loginButton.tap()
    }
}

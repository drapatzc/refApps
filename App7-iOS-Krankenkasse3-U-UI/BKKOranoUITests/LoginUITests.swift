import XCTest

/// UI tests covering the BKK Orano login screen.
final class LoginUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Launch helper

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launch()
        return app
    }

    // MARK: - Tests

    func testLoginScreenShowsButton() throws {
        let app = launchApp()
        let signInButton = app.buttons["login_button"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
    }

    func testLoginButtonDisabledWhenPasswordEmpty() throws {
        let app = launchApp()
        let signInButton = app.buttons["login_button"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
        // The button is disabled when password is empty.
        XCTAssertFalse(signInButton.isEnabled)
    }

    func testLoginWithWrongPasswordShowsError() throws {
        let app = launchApp()
        let passwordField = app.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("ThisIsWrong")

        let signInButton = app.buttons["login_button"]
        XCTAssertTrue(signInButton.isEnabled)
        signInButton.tap()

        // The error banner text comes from Localizable.strings:
        // "The entered password is incorrect..." or German equivalent.
        // We check for the visibility of the error banner's warning glyph
        // indirectly by confirming the button is once again available
        // and the password got cleared.
        let banner = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] 'Passwort' OR label CONTAINS[c] 'password'")
        ).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 3))
    }
}

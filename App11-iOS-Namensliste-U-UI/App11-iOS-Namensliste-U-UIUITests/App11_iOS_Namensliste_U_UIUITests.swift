import XCTest

final class App11_iOS_Namensliste_U_UIUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - UITest 1: Neuen Namen hinzufügen

    func testNeuenNamenHinzufuegen() throws {
        app.navigationBars.buttons["Neuen Namen hinzufügen"].tap()

        let vornameField = app.textFields["Vorname eingeben"]
        XCTAssertTrue(vornameField.waitForExistence(timeout: 5))
        vornameField.tap()
        vornameField.typeText("Max")

        let nachnameField = app.textFields["Nachnamen eingeben"]
        nachnameField.tap()
        nachnameField.typeText("Mustermann")

        app.buttons["Speichern"].tap()

        XCTAssertTrue(
            app.staticTexts["Mustermann, Max"].waitForExistence(timeout: 5),
            "Neuer Eintrag sollte in der Liste erscheinen"
        )
    }

    // MARK: - UITest 2: Abbrechen schließt Dialog

    func testAbbrechenSchliesstDialog() throws {
        app.navigationBars.buttons["Neuen Namen hinzufügen"].tap()

        XCTAssertTrue(app.buttons["Abbrechen"].waitForExistence(timeout: 5))
        app.buttons["Abbrechen"].tap()

        XCTAssertFalse(
            app.textFields["Vorname eingeben"].exists,
            "Formular sollte nach Abbrechen geschlossen sein"
        )
    }
}

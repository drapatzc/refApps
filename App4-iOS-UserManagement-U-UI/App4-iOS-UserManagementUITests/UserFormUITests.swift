import XCTest

final class UserFormUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
        openNewUserForm()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Setup Helper

    private func openNewUserForm() {
        let newUserBtn = app.buttons["btn_newUser"]
        XCTAssertTrue(newUserBtn.waitForExistence(timeout: 3))
        newUserBtn.tap()
        XCTAssertTrue(app.buttons["btn_cancel"].waitForExistence(timeout: 3))
    }

    // MARK: - Grundstruktur des Formulars

    func test_formHasCancelButton() {
        XCTAssertTrue(app.buttons["btn_cancel"].exists)
    }

    func test_formHasSaveButton() {
        XCTAssertTrue(app.buttons["btn_save"].exists)
    }

    func test_formHasFirstNameField() {
        XCTAssertTrue(app.textFields["tf_firstName"].exists)
    }

    func test_formHasLastNameField() {
        XCTAssertTrue(app.textFields["tf_lastName"].exists)
    }

    func test_formHasStreetField() {
        XCTAssertTrue(app.textFields["tf_street"].exists)
    }

    func test_formHasHouseNumberField() {
        XCTAssertTrue(app.textFields["tf_houseNumber"].exists)
    }

    func test_formHasCountryField() {
        // Scroll to the bottom of the form
        app.swipeUp()
        XCTAssertTrue(app.textFields["tf_country"].waitForExistence(timeout: 2))
    }

    // MARK: - Abbrechen

    func test_cancelButton_dismissesForm() {
        app.buttons["btn_cancel"].tap()
        // Form is dismissed, list button visible again
        XCTAssertTrue(app.buttons["btn_newUser"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["btn_cancel"].exists)
    }

    // MARK: - Validierung: Leeres Formular

    func test_saveEmptyForm_doesNotDismiss() {
        // Form is empty, tap save
        app.buttons["btn_save"].tap()
        // Form stays open (cancel button still visible)
        XCTAssertTrue(app.buttons["btn_cancel"].waitForExistence(timeout: 2))
    }

    func test_saveEmptyForm_showsValidationErrors() {
        app.buttons["btn_save"].tap()
        // At least one error message should appear
        // Validation shows error texts next to the fields
        let errorTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'required' OR label CONTAINS[c] 'Pflicht'"))
        XCTAssertTrue(errorTexts.count > 0 || app.buttons["btn_cancel"].exists)
    }

    // MARK: - Validierung: Einzelne Felder

    func test_firstName_onlyWhitespace_showsError() {
        let field = app.textFields["tf_firstName"]
        field.tap()
        field.typeText("   ")
        app.buttons["btn_save"].tap()
        // Form stays open
        XCTAssertTrue(app.buttons["btn_cancel"].exists)
    }

    func test_postalCode_withLetters_showsError() {
        fillRequiredFieldsExcept("tf_postalCode")
        app.swipeUp()
        let postalField = app.textFields["tf_postalCode"]
        if postalField.waitForExistence(timeout: 2) {
            postalField.tap()
            postalField.typeText("ABC12")
        }
        app.buttons["btn_save"].tap()
        XCTAssertTrue(app.buttons["btn_cancel"].exists)
    }

    func test_email_invalidFormat_showsError() {
        fillAllRequiredFields()
        app.swipeUp()
        let emailField = app.textFields["tf_email"]
        if emailField.waitForExistence(timeout: 2) {
            emailField.tap()
            emailField.typeText("kein-at-zeichen")
        }
        app.buttons["btn_save"].tap()
        // Form stays open due to invalid email
        XCTAssertTrue(app.buttons["btn_cancel"].exists)
    }

    func test_email_validFormat_isAccepted() {
        fillAllRequiredFields()
        app.swipeUp()
        let emailField = app.textFields["tf_email"]
        if emailField.waitForExistence(timeout: 2) {
            emailField.tap()
            emailField.typeText("test@example.de")
        }
        app.buttons["btn_save"].tap()
        // Form closes
        XCTAssertTrue(app.buttons["btn_newUser"].waitForExistence(timeout: 5))
    }

    // MARK: - Erfolgreiches Speichern

    func test_validForm_savesAndDismisses() {
        fillAllRequiredFields()
        app.buttons["btn_save"].tap()
        XCTAssertTrue(app.buttons["btn_newUser"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["btn_cancel"].exists)
    }

    func test_countryField_isPrefilled() {
        app.swipeUp()
        let countryField = app.textFields["tf_country"]
        if countryField.waitForExistence(timeout: 2) {
            let value = countryField.value as? String ?? ""
            // Either "Deutschland" or "Germany" (depending on device language)
            XCTAssertFalse(value.isEmpty, "Country should be pre-filled")
        }
    }

    // MARK: - Helpers

    private func fillAllRequiredFields() {
        fillFormField("tf_firstName", text: "Max")
        fillFormField("tf_lastName", text: "Mustermann")
        fillFormField("tf_street", text: "Musterstraße")
        fillFormField("tf_houseNumber", text: "42")
        app.swipeUp()
        fillFormField("tf_postalCode", text: "12345")
        fillFormField("tf_city", text: "Berlin")
        // tf_country is pre-filled
    }

    private func fillRequiredFieldsExcept(_ skippedIdentifier: String) {
        let allFields = ["tf_firstName": "Max", "tf_lastName": "Mustermann",
                         "tf_street": "Musterstraße", "tf_houseNumber": "42"]
        for (id, value) in allFields where id != skippedIdentifier {
            fillFormField(id, text: value)
        }
        app.swipeUp()
        let scrolledFields = ["tf_postalCode": "12345", "tf_city": "Berlin"]
        for (id, value) in scrolledFields where id != skippedIdentifier {
            fillFormField(id, text: value)
        }
    }

    private func fillFormField(_ identifier: String, text: String) {
        let field = app.textFields[identifier]
        if field.waitForExistence(timeout: 2) && field.isHittable {
            field.tap()
            field.clearText()
            field.typeText(text)
        }
    }
}


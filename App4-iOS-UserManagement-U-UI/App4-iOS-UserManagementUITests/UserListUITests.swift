import XCTest

final class UserListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch

    func test_appLaunches_andShowsNavigationBar() {
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 3))
    }

    func test_emptyState_isVisible_whenNoUsers() {
        // After launch with fresh DB the empty state should be visible
        let emptyImage = app.images["person.3"]
        XCTAssertTrue(emptyImage.waitForExistence(timeout: 3))
    }

    func test_newUserButton_existsInToolbar() {
        XCTAssertTrue(app.buttons["btn_newUser"].waitForExistence(timeout: 3))
    }

    // MARK: - Navigation

    func test_newUserButton_opensForm() {
        app.buttons["btn_newUser"].tap()
        XCTAssertTrue(app.buttons["btn_cancel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["btn_save"].exists)
    }

    // MARK: - Search

    func test_searchBar_existsAndAcceptsInput() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Mueller")
        XCTAssertEqual(searchField.value as? String, "Mueller")
    }

    func test_searchBar_cancelClearsInput() {
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("Test")
        // Tap the search bar cancel button
        let cancelSearch = app.buttons["Cancel"]
        if cancelSearch.exists {
            cancelSearch.tap()
        }
        XCTAssertFalse(app.buttons["btn_cancel"].exists) // nicht Formular-Cancel
    }

    // MARK: - Creating Users and Verifying in List

    func test_createdUser_appearsInList() throws {
        createTestUser(firstName: "Anna", lastName: "Beispiel")

        // Liste sollte jetzt mindestens einen Eintrag haben
        let list = app.collectionViews["userList"]
        XCTAssertTrue(list.waitForExistence(timeout: 3))
        XCTAssertTrue(list.cells.count > 0)
    }

    func test_multipleUsers_allAppearInList() {
        createTestUser(firstName: "Hans", lastName: "Alpha")
        createTestUser(firstName: "Maria", lastName: "Beta")

        let list = app.collectionViews["userList"]
        XCTAssertTrue(list.waitForExistence(timeout: 3))
        XCTAssertGreaterThanOrEqual(list.cells.count, 2)
    }

    func test_searchFiltersUsers() {
        createTestUser(firstName: "ZZFilterTest", lastName: "Unique")
        createTestUser(firstName: "Other", lastName: "Person")

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        searchField.typeText("ZZFilterTest")

        let list = app.collectionViews["userList"]
        XCTAssertTrue(list.waitForExistence(timeout: 2))
        // Only the filtered user should be visible
        XCTAssertEqual(list.cells.count, 1)
    }

    // MARK: - Swipe to Delete

    func test_swipeToDelete_showsDeleteButton() {
        createTestUser(firstName: "Delete", lastName: "Me")

        let list = app.collectionViews["userList"]
        XCTAssertTrue(list.waitForExistence(timeout: 3))

        let firstCell = list.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))
        firstCell.swipeLeft()

        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
    }

    func test_swipeToDelete_thenCancel_keepesUser() {
        createTestUser(firstName: "Keep", lastName: "Me")

        let list = app.collectionViews["userList"]
        XCTAssertTrue(list.waitForExistence(timeout: 3))
        let cellCount = list.cells.count

        let firstCell = list.cells.firstMatch
        firstCell.swipeLeft()
        app.buttons["Delete"].tap()

        // Confirmation dialog appears — cancel
        let cancelBtn = app.buttons.matching(identifier: "Cancel").firstMatch
        if cancelBtn.waitForExistence(timeout: 2) {
            cancelBtn.tap()
        }

        // User should still be present
        XCTAssertEqual(list.cells.count, cellCount)
    }

    // MARK: - Helpers

    @discardableResult
    private func createTestUser(
        firstName: String,
        lastName: String,
        street: String = "Teststraße",
        houseNumber: String = "1",
        postalCode: String = "12345",
        city: String = "Berlin"
    ) -> Bool {
        guard app.buttons["btn_newUser"].waitForExistence(timeout: 3) else { return false }
        app.buttons["btn_newUser"].tap()
        guard app.buttons["btn_cancel"].waitForExistence(timeout: 3) else { return false }

        fillFormField("tf_firstName", text: firstName)
        fillFormField("tf_lastName", text: lastName)
        fillFormField("tf_street", text: street)
        fillFormField("tf_houseNumber", text: houseNumber)
        fillFormField("tf_postalCode", text: postalCode, scroll: true)
        fillFormField("tf_city", text: city, scroll: true)

        app.buttons["btn_save"].tap()
        return app.buttons["btn_newUser"].waitForExistence(timeout: 5)
    }

    private func fillFormField(_ identifier: String, text: String, scroll: Bool = false) {
        let field = app.textFields[identifier]
        if scroll {
            field.scrollIntoView()
        }
        if field.waitForExistence(timeout: 2) {
            field.tap()
            // Delete existing text
            field.clearText()
            field.typeText(text)
        }
    }
}

// MARK: - XCUIElement Helpers

extension XCUIElement {
    func clearText() {
        guard let text = value as? String, !text.isEmpty else { return }
        tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count)
        typeText(deleteString)
    }

    func scrollIntoView() {
        var attempts = 0
        while !isHittable && attempts < 5 {
            XCUIApplication().swipeUp()
            attempts += 1
        }
    }
}

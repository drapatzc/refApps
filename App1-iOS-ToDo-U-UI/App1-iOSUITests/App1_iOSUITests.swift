import XCTest

/// UI tests for the App1-iOS Todo app.
/// Verifies basic user interactions and navigation.
final class App1_iOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch

    func testAppStartsSuccessfully() {
        XCTAssert(app.state == .runningForeground, "The app should be running in the foreground.")
    }

    func testListViewIsVisible() {
        XCTAssertTrue(
            app.navigationBars["Meine Todos"].exists,
            "The navigation bar with 'Meine Todos' should be visible."
        )
    }

    // MARK: - Navigation

    func testAddButtonNavigatesToAddTodoView() {
        let addButton = app.buttons["addTodoButton"]
        XCTAssertTrue(addButton.exists, "The add button should be present.")
        addButton.tap()
        XCTAssertTrue(
            app.navigationBars["Neues Todo"].waitForExistence(timeout: 2.0),
            "The add todo view should appear."
        )
    }

    func testCancelDismissesAddTodoView() {
        app.buttons["addTodoButton"].tap()
        XCTAssertTrue(app.navigationBars["Neues Todo"].waitForExistence(timeout: 2.0))
        app.buttons["Abbrechen"].tap()
        XCTAssertTrue(
            app.navigationBars["Meine Todos"].waitForExistence(timeout: 2.0),
            "The list should be visible again after cancelling."
        )
    }

    // MARK: - Creating Todos

    func testNewTodoCanBeCreated() {
        app.buttons["addTodoButton"].tap()

        let titleField = app.textFields["todoTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2.0), "The title field should appear.")
        titleField.tap()
        titleField.typeText("Mein erstes UI-Test-Todo")

        let saveButton = app.buttons["saveTodoButton"]
        XCTAssertTrue(saveButton.isEnabled, "The save button should be enabled.")
        saveButton.tap()

        XCTAssertTrue(
            app.staticTexts["Mein erstes UI-Test-Todo"].waitForExistence(timeout: 2.0),
            "The new todo should appear in the list."
        )
    }

    func testSaveButtonIsDisabledForEmptyTitle() {
        app.buttons["addTodoButton"].tap()
        let saveButton = app.buttons["saveTodoButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2.0))
        XCTAssertFalse(
            saveButton.isEnabled,
            "The save button should be disabled when the title is empty."
        )
    }

    func testMultipleTodosCanBeCreated() {
        let titles = ["Einkaufen", "Sport", "Lesen"]
        for title in titles {
            app.buttons["addTodoButton"].tap()
            let titleField = app.textFields["todoTitleField"]
            XCTAssertTrue(titleField.waitForExistence(timeout: 2.0))
            titleField.tap()
            titleField.typeText(title)
            app.buttons["saveTodoButton"].tap()
            XCTAssertTrue(app.navigationBars["Meine Todos"].waitForExistence(timeout: 2.0))
        }
        for title in titles {
            XCTAssertTrue(app.staticTexts[title].exists, "'\(title)' should appear in the list.")
        }
    }
}

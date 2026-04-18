import XCTest

/// UI tests for the App2-MacOS task management app.
/// Verifies basic user interactions and navigation.
final class App2_MacOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        // Wait until the main window and toolbar are fully loaded
        _ = app.windows.firstMatch.waitForExistence(timeout: 5.0)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch

    func testAppStartsSuccessfully() {
        XCTAssert(app.state == .runningForeground, "The app should be running in the foreground.")
    }

    func testTaskListIsVisible() {
        let taskList = app.outlines["taskList"].firstMatch
        XCTAssertTrue(
            taskList.exists || app.tables["taskList"].exists,
            "The task list should be visible in the sidebar."
        )
    }

    func testWindowTitleIsVisible() {
        XCTAssertTrue(
            app.windows.firstMatch.exists,
            "The main window should be present."
        )
    }

    // MARK: - New Task

    func testAddTaskButtonIsVisible() {
        let addButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "The add button should be visible.")
    }

    func testNewTaskCanBeCreated() {
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()

        let titleField = app.textFields["taskTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3.0), "The title field should appear.")
        titleField.click()
        titleField.typeText("Meine Test-Aufgabe")

        let confirmButton = app.buttons["addTaskConfirmButton"]
        XCTAssertTrue(confirmButton.isEnabled, "The add button should be enabled.")
        confirmButton.click()

        XCTAssertTrue(
            app.staticTexts["Meine Test-Aufgabe"].waitForExistence(timeout: 2.0),
            "The new task should appear in the list."
        )
    }

    func testAddTaskConfirmButtonIsDisabledWithEmptyTitle() {
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()
        let confirmButton = app.buttons["addTaskConfirmButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3.0))
        XCTAssertFalse(
            confirmButton.isEnabled,
            "The confirm button should be disabled when the title is empty."
        )
    }

    func testCancelDismissesAddTaskSheet() {
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()
        XCTAssertTrue(app.textFields["taskTitleField"].waitForExistence(timeout: 3.0))
        app.buttons["Abbrechen"].click()
        XCTAssertFalse(
            app.textFields["taskTitleField"].waitForExistence(timeout: 1.0),
            "The input form should disappear after cancelling."
        )
    }

    // MARK: - Selecting a Task

    func testSelectingTaskShowsDetailView() {
        // Create a task
        XCTAssertTrue(app.buttons["addTaskButton"].waitForExistence(timeout: 5.0))
        app.buttons["addTaskButton"].click()
        let titleField = app.textFields["taskTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3.0))
        titleField.click()
        titleField.typeText("Detail-Test-Aufgabe")
        app.buttons["addTaskConfirmButton"].click()

        // Select the task
        XCTAssertTrue(app.staticTexts["Detail-Test-Aufgabe"].waitForExistence(timeout: 2.0))
        app.staticTexts["Detail-Test-Aufgabe"].click()

        // Verify the detail area
        XCTAssertTrue(
            app.buttons["deleteTaskButton"].waitForExistence(timeout: 2.0),
            "The delete button should be visible in the detail area."
        )
    }
}

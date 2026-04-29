import XCTest

/// UI tests for the App2-MacOS task management app.
/// Uses --uitesting launch argument to start with in-memory persistence and no sample data.
final class App2_MacOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        app.activate()
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
        XCTAssertTrue(app.windows.firstMatch.exists, "The main window should be present.")
    }

    // MARK: - New Task

    func testAddTaskSheetOpensViaShortcut() {
        // Cmd+N is the canonical way to open the add task sheet (menu + toolbar button).
        openAddTaskSheet()
        XCTAssertTrue(
            app.textFields["taskTitleField"].waitForExistence(timeout: 3.0),
            "The add task sheet should open via Cmd+N."
        )
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
    }

    func testNewTaskCanBeCreated() {
        openAddTaskSheet()

        let titleField = app.textFields["taskTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3.0), "The title field should appear.")
        titleField.click()
        titleField.typeText("Meine Test-Aufgabe")

        let confirmButton = app.buttons["addTaskConfirmButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2.0))
        XCTAssertTrue(confirmButton.isEnabled, "The add button should be enabled after typing a title.")
        confirmButton.click()

        XCTAssertTrue(
            app.staticTexts["Meine Test-Aufgabe"].waitForExistence(timeout: 5.0),
            "The new task should appear in the list."
        )
    }

    func testAddTaskConfirmButtonIsDisabledWithEmptyTitle() {
        openAddTaskSheet()
        let confirmButton = app.buttons["addTaskConfirmButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3.0))
        XCTAssertFalse(
            confirmButton.isEnabled,
            "The confirm button should be disabled when the title is empty."
        )
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
    }

    func testCancelDismissesAddTaskSheet() {
        openAddTaskSheet()
        XCTAssertTrue(app.textFields["taskTitleField"].waitForExistence(timeout: 3.0))
        app.buttons["Abbrechen"].click()
        XCTAssertFalse(
            app.textFields["taskTitleField"].waitForExistence(timeout: 2.0),
            "The input form should disappear after cancelling."
        )
    }

    // MARK: - Selecting a Task

    func testSelectingTaskShowsDetailView() {
        createTask(title: "Detail-Test-Aufgabe")

        XCTAssertTrue(app.staticTexts["Detail-Test-Aufgabe"].waitForExistence(timeout: 5.0))
        app.staticTexts["Detail-Test-Aufgabe"].click()

        // Delete button lives in the detail view toolbar (individual ToolbarItem).
        let deleteButton = app.windows.firstMatch.buttons["deleteTaskButton"]
        XCTAssertTrue(
            deleteButton.waitForExistence(timeout: 3.0),
            "The delete button should be visible after task selection."
        )
    }

    func testEditButtonIsVisibleAfterTaskSelection() {
        createTask(title: "Edit-Test-Aufgabe")

        XCTAssertTrue(app.staticTexts["Edit-Test-Aufgabe"].waitForExistence(timeout: 5.0))
        app.staticTexts["Edit-Test-Aufgabe"].click()

        let editButton = app.windows.firstMatch.buttons["editTaskButton"]
        XCTAssertTrue(
            editButton.waitForExistence(timeout: 3.0),
            "The edit button should be visible in the detail toolbar."
        )
    }

    func testEditTaskSheetOpens() {
        createTask(title: "Zu bearbeitende Aufgabe")

        XCTAssertTrue(app.staticTexts["Zu bearbeitende Aufgabe"].waitForExistence(timeout: 5.0))
        app.staticTexts["Zu bearbeitende Aufgabe"].click()

        let editButton = app.windows.firstMatch.buttons["editTaskButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3.0))
        editButton.click()

        XCTAssertTrue(
            app.textFields["editTaskTitleField"].waitForExistence(timeout: 3.0),
            "The edit form should open with a pre-filled title field."
        )
    }

    // MARK: - Helpers

    /// Öffnet das Formular für neue Aufgaben via Cmd+N.
    private func openAddTaskSheet() {
        app.typeKey("n", modifierFlags: .command)
    }

    /// Erstellt eine neue Aufgabe mit dem gegebenen Titel.
    private func createTask(title: String) {
        openAddTaskSheet()
        let titleField = app.textFields["taskTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3.0))
        titleField.click()
        titleField.typeText(title)
        app.buttons["addTaskConfirmButton"].click()
    }
}

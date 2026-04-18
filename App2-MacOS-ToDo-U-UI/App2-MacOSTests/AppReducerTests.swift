import Testing
import Foundation
@testable import App2_MacOS

/// Tests for the pure reducer function.
/// Since the reducer is a pure function, all cases can be tested without mocks.
struct AppReducerTests {

    // MARK: - addTask

    @Test("Task is added correctly")
    func taskIsAddedCorrectly() {
        let state = AppState()
        let action = AppAction.addTask(title: "Neue Aufgabe", description: "Beschreibung", priority: .high)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.count == 1)
        #expect(newState.tasks.first?.title == "Neue Aufgabe")
        #expect(newState.tasks.first?.taskDescription == "Beschreibung")
        #expect(newState.tasks.first?.priority == .high)
        #expect(newState.tasks.first?.status == .todo)
        #expect(newState.isAddTaskPresented == false)
        #expect(newState.errorMessage == nil)
    }

    @Test("Empty title sets error message and no task is added")
    func emptyTitleSetsErrorMessageAndNoTaskAdded() {
        let state = AppState()
        let action = AppAction.addTask(title: "   ", description: "", priority: .medium)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.isEmpty)
        #expect(newState.errorMessage != nil)
    }

    @Test("Title is trimmed on add")
    func titleIsTrimmedOnAdd() {
        let state = AppState()
        let action = AppAction.addTask(title: "  Aufgabe  ", description: "", priority: .low)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.title == "Aufgabe")
    }

    // MARK: - updateTaskStatus

    @Test("Task status is updated correctly")
    func taskStatusIsUpdatedCorrectly() {
        var state = AppState()
        let task = WorkTask(title: "Test", status: .todo)
        state.tasks = [task]

        let action = AppAction.updateTaskStatus(id: task.id, newStatus: .inProgress)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.status == .inProgress)
    }

    @Test("Update on non-existent ID has no effect")
    func updateNonExistentTaskHasNoEffect() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Vorhandene Aufgabe")]
        let action = AppAction.updateTaskStatus(id: UUID(), newStatus: .done)
        let newState = appReducer(state: state, action: action)
        #expect(newState.tasks.first?.status == .todo)
    }

    // MARK: - deleteTask

    @Test("Task is deleted correctly")
    func taskIsDeletedCorrectly() {
        var state = AppState()
        let task = WorkTask(title: "Zu löschen")
        state.tasks = [task]
        state.selectedTaskID = task.id

        let action = AppAction.deleteTask(id: task.id)
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.isEmpty)
        #expect(newState.selectedTaskID == nil)
    }

    @Test("Deleting another task does not clear the selection")
    func deletingOtherTaskKeepsSelection() {
        var state = AppState()
        let selectedTask = WorkTask(title: "Ausgewählt")
        let otherTask = WorkTask(title: "Anderer")
        state.tasks = [selectedTask, otherTask]
        state.selectedTaskID = selectedTask.id

        let action = AppAction.deleteTask(id: otherTask.id)
        let newState = appReducer(state: state, action: action)

        #expect(newState.selectedTaskID == selectedTask.id)
    }

    // MARK: - selectTask

    @Test("Task is selected correctly")
    func taskIsSelectedCorrectly() {
        let state = AppState()
        let taskID = UUID()
        let newState = appReducer(state: state, action: .selectTask(id: taskID))
        #expect(newState.selectedTaskID == taskID)
    }

    @Test("Selection is reset with nil")
    func selectionIsResetWithNil() {
        var state = AppState()
        state.selectedTaskID = UUID()
        let newState = appReducer(state: state, action: .selectTask(id: nil))
        #expect(newState.selectedTaskID == nil)
    }

    // MARK: - setFilter

    @Test("Filter is set correctly")
    func filterIsSetCorrectly() {
        let state = AppState()
        let newState = appReducer(state: state, action: .setFilter(status: .done))
        #expect(newState.filterStatus == .done)
    }

    @Test("Filter is reset with nil")
    func filterIsResetWithNil() {
        var state = AppState()
        state.filterStatus = .done
        let newState = appReducer(state: state, action: .setFilter(status: nil))
        #expect(newState.filterStatus == nil)
    }

    // MARK: - showAddTask / hideAddTask

    @Test("showAddTask sets isAddTaskPresented to true")
    func showAddTaskSetsFlag() {
        let state = AppState()
        let newState = appReducer(state: state, action: .showAddTask)
        #expect(newState.isAddTaskPresented == true)
    }

    @Test("hideAddTask sets isAddTaskPresented to false")
    func hideAddTaskClearsFlag() {
        var state = AppState()
        state.isAddTaskPresented = true
        let newState = appReducer(state: state, action: .hideAddTask)
        #expect(newState.isAddTaskPresented == false)
    }

    // MARK: - clearError

    @Test("clearError removes the error message")
    func clearErrorRemovesErrorMessage() {
        var state = AppState()
        state.errorMessage = "Ein Fehler ist aufgetreten"
        let newState = appReducer(state: state, action: .clearError)
        #expect(newState.errorMessage == nil)
    }
}

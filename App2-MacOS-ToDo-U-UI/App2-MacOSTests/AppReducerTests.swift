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
        let action = AppAction.addTask(
            title: "Neue Aufgabe",
            description: "Beschreibung",
            priority: .high,
            dueDate: nil,
            category: .work,
            tags: ["tag1"]
        )
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.count == 1)
        #expect(newState.tasks.first?.title == "Neue Aufgabe")
        #expect(newState.tasks.first?.taskDescription == "Beschreibung")
        #expect(newState.tasks.first?.priority == .high)
        #expect(newState.tasks.first?.status == .todo)
        #expect(newState.tasks.first?.category == .work)
        #expect(newState.tasks.first?.tags == ["tag1"])
        #expect(newState.isAddTaskPresented == false)
        #expect(newState.errorMessage == nil)
    }

    @Test("Empty title sets error message and no task is added")
    func emptyTitleSetsErrorMessageAndNoTaskAdded() {
        let state = AppState()
        let action = AppAction.addTask(
            title: "   ", description: "", priority: .medium,
            dueDate: nil, category: .general, tags: []
        )
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.isEmpty)
        #expect(newState.errorMessage != nil)
    }

    @Test("Title is trimmed on add")
    func titleIsTrimmedOnAdd() {
        let state = AppState()
        let action = AppAction.addTask(
            title: "  Aufgabe  ", description: "", priority: .low,
            dueDate: nil, category: .general, tags: []
        )
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.title == "Aufgabe")
    }

    @Test("Due date is stored correctly on add")
    func dueDateIsStoredOnAdd() {
        let state = AppState()
        let dueDate = Date()
        let action = AppAction.addTask(
            title: "Mit Datum", description: "", priority: .medium,
            dueDate: dueDate, category: .general, tags: []
        )
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.dueDate == dueDate)
    }

    // MARK: - updateTask

    @Test("updateTask updates all fields of an existing task")
    func updateTaskUpdatesAllFields() {
        var state = AppState()
        let task = WorkTask(title: "Alt", priority: .low, status: .todo)
        state.tasks = [task]

        let newDueDate = Date()
        let action = AppAction.updateTask(
            id: task.id,
            title: "Neu",
            description: "Neue Beschreibung",
            priority: .high,
            status: .done,
            dueDate: newDueDate,
            category: .work,
            tags: ["tag1", "tag2"]
        )
        let newState = appReducer(state: state, action: action)

        let updated = newState.tasks.first!
        #expect(updated.title == "Neu")
        #expect(updated.taskDescription == "Neue Beschreibung")
        #expect(updated.priority == .high)
        #expect(updated.status == .done)
        #expect(updated.dueDate == newDueDate)
        #expect(updated.category == .work)
        #expect(updated.tags == ["tag1", "tag2"])
        #expect(newState.isEditTaskPresented == false)
        #expect(newState.editingTaskID == nil)
    }

    @Test("updateTask with empty title sets error and does not update")
    func updateTaskWithEmptyTitleSetsError() {
        var state = AppState()
        let task = WorkTask(title: "Original")
        state.tasks = [task]

        let action = AppAction.updateTask(
            id: task.id, title: "   ", description: "",
            priority: .medium, status: .todo,
            dueDate: nil, category: .general, tags: []
        )
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.title == "Original")
        #expect(newState.errorMessage != nil)
    }

    @Test("updateTask on non-existent ID has no effect")
    func updateTaskNonExistentIDHasNoEffect() {
        var state = AppState()
        let task = WorkTask(title: "Vorhanden")
        state.tasks = [task]

        let action = AppAction.updateTask(
            id: UUID(), title: "Irgendwas", description: "",
            priority: .high, status: .done,
            dueDate: nil, category: .general, tags: []
        )
        let newState = appReducer(state: state, action: action)

        #expect(newState.tasks.first?.title == "Vorhanden")
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

    // MARK: - setFilter / setCategoryFilter

    @Test("Status filter is set correctly")
    func filterIsSetCorrectly() {
        let state = AppState()
        let newState = appReducer(state: state, action: .setFilter(status: .done))
        #expect(newState.filterStatus == .done)
    }

    @Test("Status filter is reset with nil")
    func filterIsResetWithNil() {
        var state = AppState()
        state.filterStatus = .done
        let newState = appReducer(state: state, action: .setFilter(status: nil))
        #expect(newState.filterStatus == nil)
    }

    @Test("Category filter is set correctly")
    func categoryFilterIsSetCorrectly() {
        let state = AppState()
        let newState = appReducer(state: state, action: .setCategoryFilter(category: .work))
        #expect(newState.filterCategory == .work)
    }

    @Test("Category filter is reset with nil")
    func categoryFilterIsResetWithNil() {
        var state = AppState()
        state.filterCategory = .work
        let newState = appReducer(state: state, action: .setCategoryFilter(category: nil))
        #expect(newState.filterCategory == nil)
    }

    // MARK: - setSearchQuery / setSortOrder

    @Test("Search query is updated")
    func searchQueryIsUpdated() {
        let state = AppState()
        let newState = appReducer(state: state, action: .setSearchQuery("Swift"))
        #expect(newState.searchQuery == "Swift")
    }

    @Test("Sort order is updated")
    func sortOrderIsUpdated() {
        let state = AppState()
        let newState = appReducer(state: state, action: .setSortOrder(.title))
        #expect(newState.sortOrder == .title)
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

    // MARK: - showEditTask / hideEditTask

    @Test("showEditTask sets editingTaskID and flag")
    func showEditTaskSetsFlags() {
        let state = AppState()
        let taskID = UUID()
        let newState = appReducer(state: state, action: .showEditTask(id: taskID))
        #expect(newState.isEditTaskPresented == true)
        #expect(newState.editingTaskID == taskID)
    }

    @Test("hideEditTask clears editingTaskID and flag")
    func hideEditTaskClearsFlags() {
        var state = AppState()
        state.isEditTaskPresented = true
        state.editingTaskID = UUID()
        let newState = appReducer(state: state, action: .hideEditTask)
        #expect(newState.isEditTaskPresented == false)
        #expect(newState.editingTaskID == nil)
    }

    // MARK: - clearError

    @Test("clearError removes the error message")
    func clearErrorRemovesErrorMessage() {
        var state = AppState()
        state.errorMessage = "Ein Fehler ist aufgetreten"
        let newState = appReducer(state: state, action: .clearError)
        #expect(newState.errorMessage == nil)
    }

    // MARK: - loadSampleData

    @Test("loadSampleData populates the tasks array")
    func loadSampleDataPopulatesTasks() {
        let state = AppState()
        let newState = appReducer(state: state, action: .loadSampleData)
        #expect(!newState.tasks.isEmpty)
    }

    @Test("loadSampleData creates tasks with diverse categories")
    func loadSampleDataCreatesDiverseCategories() {
        let state = AppState()
        let newState = appReducer(state: state, action: .loadSampleData)
        let categories = Set(newState.tasks.map(\.category))
        #expect(categories.count > 1)
    }

    @Test("loadSampleData creates tasks with mixed statuses")
    func loadSampleDataCreatesMixedStatuses() {
        let state = AppState()
        let newState = appReducer(state: state, action: .loadSampleData)
        let statuses = Set(newState.tasks.map(\.status))
        #expect(statuses.count > 1)
    }
}

import Testing
import Foundation
@testable import App2_MacOS

/// Tests for computed properties of AppState.
struct AppStateTests {

    // MARK: - filteredTasks

    @Test("All tasks are returned without a filter")
    func allTasksReturnedWithoutFilter() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Erster", status: .todo),
            WorkTask(title: "Zweiter", status: .done)
        ]
        #expect(state.filteredTasks.count == 2)
    }

    @Test("Filter by status returns only matching tasks")
    func filterByStatusReturnsMatchingTasksOnly() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Offen", status: .todo),
            WorkTask(title: "Erledigt", status: .done),
            WorkTask(title: "In Arbeit", status: .inProgress)
        ]
        state.filterStatus = .todo
        #expect(state.filteredTasks.count == 1)
        #expect(state.filteredTasks.first?.title == "Offen")
    }

    @Test("Empty result for non-matching filter")
    func emptyResultForNonMatchingFilter() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Offen", status: .todo)]
        state.filterStatus = .done
        #expect(state.filteredTasks.isEmpty)
    }

    // MARK: - Sorting

    @Test("filteredTasks sorts by priority (high first)")
    func filteredTasksSortsByPriorityHighFirst() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Niedrig", priority: .low),
            WorkTask(title: "Hoch", priority: .high),
            WorkTask(title: "Mittel", priority: .medium)
        ]
        let sorted = state.filteredTasks
        #expect(sorted[0].title == "Hoch")
        #expect(sorted[1].title == "Mittel")
        #expect(sorted[2].title == "Niedrig")
    }

    // MARK: - selectedTask

    @Test("selectedTask returns nil when no ID is set")
    func selectedTaskReturnsNilWithoutSelection() {
        let state = AppState()
        #expect(state.selectedTask == nil)
    }

    @Test("selectedTask returns nil when ID is not found")
    func selectedTaskReturnsNilForUnknownID() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Vorhandener Task")]
        state.selectedTaskID = UUID() // unknown ID
        #expect(state.selectedTask == nil)
    }

    @Test("selectedTask returns the correct task")
    func selectedTaskReturnsCorrectTask() {
        var state = AppState()
        let task = WorkTask(title: "Ausgewählter Task")
        state.tasks = [WorkTask(title: "Anderer"), task]
        state.selectedTaskID = task.id
        #expect(state.selectedTask?.id == task.id)
        #expect(state.selectedTask?.title == "Ausgewählter Task")
    }
}

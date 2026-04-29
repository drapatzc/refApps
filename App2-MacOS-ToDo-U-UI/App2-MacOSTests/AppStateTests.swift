import Testing
import Foundation
@testable import App2_MacOS

/// Tests for computed properties of AppState.
struct AppStateTests {

    // MARK: - filteredTasks – Status Filter

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

    @Test("Empty result for non-matching status filter")
    func emptyResultForNonMatchingFilter() {
        var state = AppState()
        state.tasks = [WorkTask(title: "Offen", status: .todo)]
        state.filterStatus = .done
        #expect(state.filteredTasks.isEmpty)
    }

    // MARK: - filteredTasks – Category Filter

    @Test("Filter by category returns only matching tasks")
    func filterByCategoryReturnsMatchingTasksOnly() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Arbeit", category: .work),
            WorkTask(title: "Persönlich", category: .personal),
            WorkTask(title: "Einkauf", category: .shopping)
        ]
        state.filterCategory = .work
        #expect(state.filteredTasks.count == 1)
        #expect(state.filteredTasks.first?.title == "Arbeit")
    }

    @Test("Status and category filter combine with AND logic")
    func statusAndCategoryFilterCombine() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Arbeit offen", status: .todo, category: .work),
            WorkTask(title: "Arbeit erledigt", status: .done, category: .work),
            WorkTask(title: "Persönlich offen", status: .todo, category: .personal)
        ]
        state.filterStatus = .todo
        state.filterCategory = .work
        #expect(state.filteredTasks.count == 1)
        #expect(state.filteredTasks.first?.title == "Arbeit offen")
    }

    // MARK: - filteredTasks – Search Query

    @Test("Search query filters by title (case-insensitive)")
    func searchQueryFiltersByTitle() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Login Bugfix"),
            WorkTask(title: "Dokumentation schreiben"),
            WorkTask(title: "Tests hinzufügen")
        ]
        state.searchQuery = "login"
        #expect(state.filteredTasks.count == 1)
        #expect(state.filteredTasks.first?.title == "Login Bugfix")
    }

    @Test("Search query filters by description")
    func searchQueryFiltersByDescription() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Task A", taskDescription: "Wichtige Aufgabe"),
            WorkTask(title: "Task B", taskDescription: "Unwichtig")
        ]
        state.searchQuery = "wichtig"
        // Both match: "Wichtige Aufgabe" and "Unwichtig"
        #expect(state.filteredTasks.count == 2)
    }

    @Test("Search query filters by tags")
    func searchQueryFiltersByTags() {
        var state = AppState()
        state.tasks = [
            WorkTask(title: "Task A", tags: ["release", "qa"]),
            WorkTask(title: "Task B", tags: ["bugfix"])
        ]
        state.searchQuery = "release"
        #expect(state.filteredTasks.count == 1)
        #expect(state.filteredTasks.first?.title == "Task A")
    }

    @Test("Empty search query returns all tasks")
    func emptySearchQueryReturnsAllTasks() {
        var state = AppState()
        state.tasks = [WorkTask(title: "A"), WorkTask(title: "B")]
        state.searchQuery = ""
        #expect(state.filteredTasks.count == 2)
    }

    // MARK: - filteredTasks – Sorting

    @Test("Default sort order is priority (high first)")
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

    @Test("Sort by title returns alphabetical order")
    func sortByTitleReturnsAlphabeticalOrder() {
        var state = AppState()
        state.sortOrder = .title
        state.tasks = [
            WorkTask(title: "Zebra"),
            WorkTask(title: "Alpha"),
            WorkTask(title: "Mitte")
        ]
        let sorted = state.filteredTasks
        #expect(sorted[0].title == "Alpha")
        #expect(sorted[1].title == "Mitte")
        #expect(sorted[2].title == "Zebra")
    }

    @Test("Sort by due date places tasks without due date last")
    func sortByDueDatePlacesNilDueDateLast() {
        let now = Date()
        let soon = now.addingTimeInterval(86_400)
        var state = AppState()
        state.sortOrder = .dueDate
        state.tasks = [
            WorkTask(title: "Kein Datum", dueDate: nil),
            WorkTask(title: "Bald", dueDate: soon),
            WorkTask(title: "Heute", dueDate: now)
        ]
        let sorted = state.filteredTasks
        #expect(sorted[0].title == "Heute")
        #expect(sorted[1].title == "Bald")
        #expect(sorted[2].title == "Kein Datum")
    }

    @Test("Sort by createdAt returns newest first")
    func sortByCreatedAtReturnsNewestFirst() {
        let base = Date()
        var state = AppState()
        state.sortOrder = .createdAt
        state.tasks = [
            WorkTask(title: "Alt", createdAt: base.addingTimeInterval(-200)),
            WorkTask(title: "Neu", createdAt: base.addingTimeInterval(0)),
            WorkTask(title: "Mittel", createdAt: base.addingTimeInterval(-100))
        ]
        let sorted = state.filteredTasks
        #expect(sorted[0].title == "Neu")
        #expect(sorted[1].title == "Mittel")
        #expect(sorted[2].title == "Alt")
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
        state.selectedTaskID = UUID()
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

    // MARK: - editingTask

    @Test("editingTask returns nil when no editingTaskID is set")
    func editingTaskReturnsNilWithoutID() {
        let state = AppState()
        #expect(state.editingTask == nil)
    }

    @Test("editingTask returns the correct task by editingTaskID")
    func editingTaskReturnsCorrectTask() {
        var state = AppState()
        let task = WorkTask(title: "Zu bearbeiten")
        state.tasks = [task]
        state.editingTaskID = task.id
        #expect(state.editingTask?.id == task.id)
    }
}

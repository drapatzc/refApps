import Testing
import Foundation
@testable import App2_MacOS

/// Tests for the AppStore.
struct AppStoreTests {

    private func makeSUT(initialTasks: [WorkTask] = []) -> (store: AppStore, persistence: MockPersistence) {
        let persistence = MockPersistence()
        persistence.tasksToLoad = initialTasks
        let store = AppStore(persistence: persistence)
        return (store, persistence)
    }

    // MARK: - Initialization

    @Test("Store loads tasks from persistence on init")
    func storeLoadsTasksOnInit() {
        let task = WorkTask(title: "Persistierter Task")
        let (store, _) = makeSUT(initialTasks: [task])
        #expect(store.state.tasks.count == 1)
        #expect(store.state.tasks.first?.title == "Persistierter Task")
    }

    @Test("Initial state has correct default values")
    func initialStateHasCorrectDefaults() {
        let (store, _) = makeSUT()
        #expect(store.state.selectedTaskID == nil)
        #expect(store.state.filterStatus == nil)
        #expect(store.state.filterCategory == nil)
        #expect(store.state.searchQuery == "")
        #expect(store.state.sortOrder == .priority)
        #expect(store.state.isAddTaskPresented == false)
        #expect(store.state.isEditTaskPresented == false)
        #expect(store.state.editingTaskID == nil)
        #expect(store.state.errorMessage == nil)
    }

    // MARK: - Dispatch

    @Test("Dispatching addTask updates the state")
    func dispatchingAddTaskUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(
            title: "Neuer Task",
            description: "",
            priority: .medium,
            dueDate: nil,
            category: .general,
            tags: []
        ))
        #expect(store.state.tasks.count == 1)
        #expect(store.state.tasks.first?.title == "Neuer Task")
    }

    @Test("Dispatch saves tasks to persistence")
    func dispatchSavesTasksToPersistence() {
        let (store, persistence) = makeSUT()
        store.dispatch(.addTask(
            title: "Test", description: "", priority: .low,
            dueDate: nil, category: .general, tags: []
        ))
        #expect(persistence.saveCallCount > 0)
        #expect(persistence.lastSavedTasks.count == 1)
    }

    @Test("Multiple dispatches stack correctly")
    func multipleDispatchesStackCorrectly() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(
            title: "Erste", description: "", priority: .high,
            dueDate: nil, category: .general, tags: []
        ))
        store.dispatch(.addTask(
            title: "Zweite", description: "", priority: .low,
            dueDate: nil, category: .general, tags: []
        ))
        #expect(store.state.tasks.count == 2)
    }

    @Test("showAddTask updates state via dispatch")
    func showAddTaskUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.showAddTask)
        #expect(store.state.isAddTaskPresented == true)
    }

    @Test("Deleting a task updates persistence")
    func deletingTaskUpdatesPersistence() {
        let task = WorkTask(title: "Zu löschen")
        let (store, persistence) = makeSUT(initialTasks: [task])
        store.dispatch(.deleteTask(id: task.id))
        #expect(persistence.lastSavedTasks.isEmpty)
    }

    @Test("Reducer error (empty title) lands in state")
    func reducerErrorLandsInState() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(
            title: "  ", description: "", priority: .medium,
            dueDate: nil, category: .general, tags: []
        ))
        #expect(store.state.errorMessage != nil)
        #expect(store.state.tasks.isEmpty)
    }

    // MARK: - New Features

    @Test("setCategoryFilter updates state via dispatch")
    func setCategoryFilterUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.setCategoryFilter(category: .work))
        #expect(store.state.filterCategory == .work)
    }

    @Test("setSearchQuery updates state via dispatch")
    func setSearchQueryUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.setSearchQuery("test"))
        #expect(store.state.searchQuery == "test")
    }

    @Test("setSortOrder updates state via dispatch")
    func setSortOrderUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.setSortOrder(.dueDate))
        #expect(store.state.sortOrder == .dueDate)
    }

    @Test("showEditTask sets editing state via dispatch")
    func showEditTaskSetsEditingState() {
        let task = WorkTask(title: "Zu bearbeiten")
        let (store, _) = makeSUT(initialTasks: [task])
        store.dispatch(.showEditTask(id: task.id))
        #expect(store.state.isEditTaskPresented == true)
        #expect(store.state.editingTaskID == task.id)
    }

    @Test("updateTask updates task and clears edit state")
    func updateTaskUpdatesAndClearsEditState() {
        let task = WorkTask(title: "Original")
        let (store, _) = makeSUT(initialTasks: [task])
        store.dispatch(.updateTask(
            id: task.id,
            title: "Geändert",
            description: "Neu",
            priority: .high,
            status: .inProgress,
            dueDate: nil,
            category: .work,
            tags: ["neuer-tag"]
        ))
        #expect(store.state.tasks.first?.title == "Geändert")
        #expect(store.state.isEditTaskPresented == false)
        #expect(store.state.editingTaskID == nil)
    }

    @Test("loadSampleData populates tasks via dispatch")
    func loadSampleDataPopulatesTasksViaDispatch() {
        let (store, _) = makeSUT()
        store.dispatch(.loadSampleData)
        #expect(!store.state.tasks.isEmpty)
    }
}

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
        #expect(store.state.isAddTaskPresented == false)
        #expect(store.state.errorMessage == nil)
    }

    // MARK: - Dispatch

    @Test("Dispatching an action updates the state")
    func dispatchingActionUpdatesState() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(title: "Neuer Task", description: "", priority: .medium))
        #expect(store.state.tasks.count == 1)
        #expect(store.state.tasks.first?.title == "Neuer Task")
    }

    @Test("Dispatch saves tasks to persistence")
    func dispatchSavesTasksToPersistence() {
        let (store, persistence) = makeSUT()
        store.dispatch(.addTask(title: "Test", description: "", priority: .low))
        #expect(persistence.saveCallCount > 0)
        #expect(persistence.lastSavedTasks.count == 1)
    }

    @Test("Multiple dispatches stack correctly")
    func multipleDispatchesStackCorrectly() {
        let (store, _) = makeSUT()
        store.dispatch(.addTask(title: "Erste", description: "", priority: .high))
        store.dispatch(.addTask(title: "Zweite", description: "", priority: .low))
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
        store.dispatch(.addTask(title: "  ", description: "", priority: .medium))
        #expect(store.state.errorMessage != nil)
        #expect(store.state.tasks.isEmpty)
    }
}

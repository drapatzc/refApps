import Foundation
@testable import App2_MacOS

/// Test double for the persistence layer.
/// Allows testing the store without real data storage.
final class MockPersistence: PersistenceProtocol {

    // MARK: - Recorded Calls

    private(set) var saveCallCount: Int = 0
    private(set) var lastSavedTasks: [WorkTask] = []

    // MARK: - Configurable State

    var tasksToLoad: [WorkTask] = []

    // MARK: - PersistenceProtocol

    func loadTasks() -> [WorkTask] {
        tasksToLoad
    }

    func saveTasks(_ tasks: [WorkTask]) {
        lastSavedTasks = tasks
        saveCallCount += 1
    }
}

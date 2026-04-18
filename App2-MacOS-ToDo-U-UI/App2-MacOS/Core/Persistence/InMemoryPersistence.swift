import Foundation

/// In-memory implementation of the persistence layer.
/// Stores tasks in RAM only – ideal for tests and prototypes.
final class InMemoryPersistence: PersistenceProtocol {

    private var tasks: [WorkTask] = []

    func loadTasks() -> [WorkTask] {
        tasks
    }

    func saveTasks(_ tasks: [WorkTask]) {
        self.tasks = tasks
    }
}

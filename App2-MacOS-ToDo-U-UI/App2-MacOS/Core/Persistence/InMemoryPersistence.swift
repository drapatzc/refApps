import Foundation

/// In-memory implementation of the persistence layer.
/// Stores tasks in RAM only – ideal for tests and UI testing.
final class InMemoryPersistence: PersistenceProtocol {

    private var tasks: [WorkTask] = []

    func loadTasks() -> [WorkTask] {
        tasks
    }

    func saveTasks(_ tasks: [WorkTask]) {
        self.tasks = tasks
    }
}

/// UserDefaults-backed persistence layer. Encodes tasks as JSON.
/// Used as the default persistence implementation in production.
final class UserDefaultsPersistence: PersistenceProtocol {

    private let storeKey = "app2_macos_tasks_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadTasks() -> [WorkTask] {
        guard let data = defaults.data(forKey: storeKey) else { return [] }
        return (try? JSONDecoder().decode([WorkTask].self, from: data)) ?? []
    }

    func saveTasks(_ tasks: [WorkTask]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: storeKey)
    }
}

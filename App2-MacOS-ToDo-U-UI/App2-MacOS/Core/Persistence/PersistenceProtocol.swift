import Foundation

/// Abstracts the persistence layer for WorkTask items.
/// Allows swapping between InMemory, UserDefaults, CoreData, CloudKit, etc.
protocol PersistenceProtocol: AnyObject {
    /// Loads all stored tasks.
    func loadTasks() -> [WorkTask]

    /// Saves a complete list of tasks.
    func saveTasks(_ tasks: [WorkTask])
}

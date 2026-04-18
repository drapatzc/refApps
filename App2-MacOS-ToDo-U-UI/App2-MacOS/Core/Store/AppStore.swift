import Foundation
import Observation

/// Central store of the application (Redux pattern).
/// Holds the current AppState and processes actions through the reducer.
/// Views observe the state directly – any change triggers a re-render.
@Observable
final class AppStore {

    // MARK: - State

    private(set) var state: AppState

    // MARK: - Dependencies

    private let reducer: (AppState, AppAction) -> AppState
    private let persistence: PersistenceProtocol

    // MARK: - Initialization

    init(
        initialState: AppState = AppState(),
        reducer: @escaping (AppState, AppAction) -> AppState = appReducer,
        persistence: PersistenceProtocol = InMemoryPersistence()
    ) {
        self.reducer = reducer
        self.persistence = persistence
        self.state = initialState
        loadFromPersistence()
    }

    // MARK: - Dispatch

    /// Processes an action: applies the reducer and saves the new state.
    func dispatch(_ action: AppAction) {
        state = reducer(state, action)
        saveToPersistence()
    }

    // MARK: - Persistence

    private func loadFromPersistence() {
        let loaded = persistence.loadTasks()
        state.tasks = loaded
    }

    private func saveToPersistence() {
        persistence.saveTasks(state.tasks)
    }
}

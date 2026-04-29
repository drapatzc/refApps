import SwiftUI

/// Entry point of the App2-MacOS task manager.
/// Creates the central AppStore and passes it to the root view.
/// Passing --uitesting as a launch argument uses in-memory storage and skips sample data.
@main
struct App2_MacOSApp: App {

    @State private var store = App2_MacOSApp.makeStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(String(localized: "new_task")) {
                    store.dispatch(.showAddTask)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }

    /// Creates the store with the appropriate persistence backend.
    /// Uses InMemoryPersistence during UI testing to ensure a clean state.
    private static func makeStore() -> AppStore {
        if CommandLine.arguments.contains("--uitesting") {
            return AppStore(persistence: InMemoryPersistence())
        }
        let persistence = UserDefaultsPersistence()
        let store = AppStore(persistence: persistence)
        if store.state.tasks.isEmpty {
            store.dispatch(.loadSampleData)
        }
        return store
    }
}

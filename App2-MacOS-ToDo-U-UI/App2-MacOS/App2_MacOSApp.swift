import SwiftUI

/// Entry point of the App2-MacOS task manager.
/// Creates the central AppStore and passes it to the root view.
@main
struct App2_MacOSApp: App {

    @State private var store = AppStore()

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
}

import SwiftUI

/// Entry point of the App1-iOS app.
/// Sets up the dependency container and launches the main view.
@main
struct App1_iOSApp: App {

    var body: some Scene {
        WindowGroup {
            TodoListView(viewModel: DependencyContainer.shared.makeTodoListViewModel())
        }
    }
}

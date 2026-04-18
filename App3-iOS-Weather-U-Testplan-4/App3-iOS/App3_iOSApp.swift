// (C) Christian Drapatz  |  https://christiandrapatz.de | https://betterlocale.com | https://atomiumgames.com

import SwiftUI

/// Entry point of the App3-iOS weather app.
/// Sets up the dependency container and launches the main view.
@main
struct App3_iOSApp: App {

    /// The root scene containing a `NavigationStack` with `CitySearchView` as the start screen.
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CitySearchView(viewModel: DependencyContainer.shared.makeCitySearchViewModel())
            }
        }
    }
}

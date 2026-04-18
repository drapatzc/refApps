import SwiftUI
import SwiftData

@main
struct App11_iOS_Namensliste_U_UIApp: App {
    var body: some Scene {
        WindowGroup {
            PersonListView()
        }
        .modelContainer(for: Person.self)
    }
}

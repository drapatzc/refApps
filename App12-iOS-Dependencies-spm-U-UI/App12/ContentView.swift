import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Animation & Images") {
                    NavigationLink("1. Lottie Animation", destination: LottieView())
                    NavigationLink("2. Kingfisher Images", destination: KingfisherView())
                    NavigationLink("3. Nuke Image Pipeline", destination: NukeView())
                }
                Section("Networking") {
                    NavigationLink("4. Alamofire REST", destination: AlamofireView())
                    NavigationLink("5. Moya Endpoints", destination: MoyaView())
                }
                Section("UI & Content") {
                    NavigationLink("6. MarkdownUI", destination: MarkdownUIView())
                    NavigationLink("11. DGCharts", destination: ChartsView())
                }
                Section("Data & Storage") {
                    NavigationLink("7. GRDB SQLite", destination: GRDBView())
                    NavigationLink("8. Defaults Settings", destination: DefaultsView())
                }
                Section("Swift Packages") {
                    NavigationLink("9. swift-dependencies", destination: DependenciesView())
                    NavigationLink("10. swift-collections", destination: CollectionsView())
                    NavigationLink("13. swift-log", destination: LoggingView())
                }
                Section("Auth & DI") {
                    NavigationLink("12. AppAuth", destination: AppAuthView())
                    NavigationLink("14. Factory DI", destination: FactoryView())
                }
                Section("Testing") {
                    NavigationLink("15. SnapshotTesting", destination: SnapshotTestingView())
                }
            }
            .navigationTitle("App12 Dependencies")
        }
    }
}

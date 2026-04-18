import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("SPM — Swift Package Manager") {
                    NavigationLink("3. Nuke Image Pipeline", destination: NukeView())
                    NavigationLink("6. MarkdownUI", destination: MarkdownUIView())
                    NavigationLink("8. Defaults Settings", destination: DefaultsView())
                    NavigationLink("9. swift-dependencies", destination: DependenciesView())
                    NavigationLink("10. swift-collections", destination: CollectionsView())
                    NavigationLink("13. swift-log", destination: LoggingView())
                    NavigationLink("15. SnapshotTesting", destination: SnapshotTestingView())
                }
                Section("CocoaPods") {
                    NavigationLink("1. Lottie Animation", destination: LottieView())
                    NavigationLink("4. Alamofire REST", destination: AlamofireView())
                    NavigationLink("5. Moya Endpoints", destination: MoyaView())
                    NavigationLink("7. GRDB SQLite", destination: GRDBView())
                    NavigationLink("14. Factory DI", destination: FactoryView())
                }
                Section("Carthage") {
                    NavigationLink("2. Kingfisher Images", destination: KingfisherView())
                    NavigationLink("11. DGCharts", destination: ChartsView())
                    NavigationLink("12. AppAuth", destination: AppAuthView())
                }
            }
            .navigationTitle("App15 Dependencies")
        }
    }
}

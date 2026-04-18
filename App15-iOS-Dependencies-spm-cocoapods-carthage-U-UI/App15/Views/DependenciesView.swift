import SwiftUI
import Dependencies

struct DependenciesView: View {
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    var body: some View {
        VStack(spacing: 16) {
            Text("swift-dependencies").font(.headline)
            Text("Date: \(date.now.formatted())")
            Text("UUID: \(uuid().uuidString.prefix(8))...")
        }
        .navigationTitle("Dependencies")
    }
}

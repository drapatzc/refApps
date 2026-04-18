import SwiftUI
// swift-collections ist nicht über Carthage verfügbar (nur SPM)

struct CollectionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("swift-collections")
                .font(.headline)
            Text("Nicht verfügbar über Carthage")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Collections")
    }
}

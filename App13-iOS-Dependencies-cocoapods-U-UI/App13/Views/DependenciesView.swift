import SwiftUI
// swift-dependencies ist nicht über CocoaPods verfügbar (nur SPM)

struct DependenciesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("swift-dependencies")
                .font(.headline)
            Text("Nicht verfügbar über CocoaPods")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Dependencies")
    }
}

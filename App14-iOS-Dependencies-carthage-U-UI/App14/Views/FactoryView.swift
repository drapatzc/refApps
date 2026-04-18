import SwiftUI
// Factory ist nicht über Carthage verfügbar (nur SPM)

struct FactoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Factory")
                .font(.headline)
            Text("Nicht verfügbar über Carthage")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Factory")
    }
}

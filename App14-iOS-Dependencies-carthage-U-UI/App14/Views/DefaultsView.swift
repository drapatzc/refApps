import SwiftUI
// Defaults ist nicht über Carthage verfügbar (nur SPM)

struct DefaultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Defaults")
                .font(.headline)
            Text("Nicht verfügbar über Carthage")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Defaults")
    }
}

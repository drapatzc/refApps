import SwiftUI
// Defaults ist nicht über CocoaPods verfügbar (nur SPM)

struct DefaultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Defaults")
                .font(.headline)
            Text("Nicht verfügbar über CocoaPods")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Defaults")
    }
}

import SwiftUI
// MarkdownUI ist nicht über Carthage verfügbar (nur SPM)

struct MarkdownUIView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("MarkdownUI")
                .font(.headline)
            Text("Nicht verfügbar über Carthage")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("MarkdownUI")
    }
}

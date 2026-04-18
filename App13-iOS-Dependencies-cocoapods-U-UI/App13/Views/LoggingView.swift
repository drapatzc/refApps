import SwiftUI
// swift-log ist nicht über CocoaPods verfügbar (nur SPM)

struct LoggingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("swift-log")
                .font(.headline)
            Text("Nicht verfügbar über CocoaPods")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Logging")
    }
}

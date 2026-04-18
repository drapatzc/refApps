import SwiftUI

struct SnapshotTestingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("SnapshotTesting").font(.headline)
            Text("SnapshotTesting from pointfreeco")
            Text("Used in unit tests for UI snapshots")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("SnapshotTesting")
    }
}

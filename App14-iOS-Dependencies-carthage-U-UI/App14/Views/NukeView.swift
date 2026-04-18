import SwiftUI
// Nuke – carthage update noch nicht ausgeführt

struct NukeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("Nuke")
                .font(.headline)
            Text("carthage update noch nicht ausgeführt")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Nuke")
    }
}

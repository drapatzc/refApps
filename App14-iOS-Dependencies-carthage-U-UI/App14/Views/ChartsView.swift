import SwiftUI
// Charts – carthage update noch nicht ausgeführt

struct ChartsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("Charts")
                .font(.headline)
            Text("carthage update noch nicht ausgeführt")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Charts")
    }
}

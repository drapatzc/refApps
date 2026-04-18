import SwiftUI
// Moya – carthage update noch nicht ausgeführt

struct MoyaView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("Moya")
                .font(.headline)
            Text("carthage update noch nicht ausgeführt")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Moya")
    }
}

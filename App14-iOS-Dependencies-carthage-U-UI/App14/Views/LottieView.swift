import SwiftUI
// lottie-ios – carthage update noch nicht ausgeführt

struct LottieView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("lottie-ios")
                .font(.headline)
            Text("carthage update noch nicht ausgeführt")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Lottie")
    }
}

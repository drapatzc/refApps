import SwiftUI
import Lottie

struct LottieView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Lottie Animation").font(.headline)
            LottieAnimationRepresentable()
                .frame(width: 200, height: 200)
            Text("Rendering: \(LottieConfiguration.shared.renderingEngine == .automatic ? "auto" : "other")")
                .font(.caption)
        }
        .navigationTitle("Lottie")
    }
}

private struct LottieAnimationRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let view = Lottie.LottieAnimationView()
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }
    func updateUIView(_ uiView: Lottie.LottieAnimationView, context: Context) {}
}

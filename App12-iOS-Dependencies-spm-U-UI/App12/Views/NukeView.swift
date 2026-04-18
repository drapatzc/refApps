import SwiftUI
import Nuke

struct NukeView: View {
    let url = URL(string: "https://picsum.photos/200/300")!
    @State private var uiImage: UIImage? = nil
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Text("Nuke Image Pipeline").font(.headline)
            Group {
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if isLoading {
                    ProgressView()
                } else {
                    Color.red
                }
            }
            .frame(width: 200, height: 200)
        }
        .navigationTitle("Nuke")
        .task {
            do {
                let response = try await ImagePipeline.shared.image(for: url)
                uiImage = response
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}

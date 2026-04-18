import SwiftUI
import Kingfisher

struct KingfisherView: View {
    let url = URL(string: "https://picsum.photos/200")!
    var body: some View {
        VStack(spacing: 16) {
            Text("Kingfisher Remote Image").font(.headline)
            KFImage(url)
                .resizable()
                .placeholder { ProgressView() }
                .frame(width: 200, height: 200)
                .cornerRadius(12)
            Text("KF version: \(KingfisherManager.shared.downloader.downloadTimeout)s timeout")
                .font(.caption)
        }
        .navigationTitle("Kingfisher")
    }
}

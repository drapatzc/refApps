import SwiftUI
import Alamofire

struct AlamofireView: View {
    @State private var status = "Tap to fetch"
    var body: some View {
        VStack(spacing: 16) {
            Text("Alamofire REST").font(.headline)
            Text(status).padding()
            Button("Fetch JSON") {
                AF.request("https://httpbin.org/get").responseString { resp in
                    switch resp.result {
                    case .success: status = "Success \u{2713}"
                    case .failure(let e): status = "Error: \(e.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Alamofire")
    }
}

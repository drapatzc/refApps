import SwiftUI
import Moya

enum SampleAPI: TargetType {
    case ping
    var baseURL: URL { URL(string: "https://httpbin.org")! }
    var path: String { "/get" }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
    var headers: [String: String]? { nil }
}

struct MoyaView: View {
    @State private var status = "Tap to request"
    private let provider = MoyaProvider<SampleAPI>()
    var body: some View {
        VStack(spacing: 16) {
            Text("Moya Endpoint").font(.headline)
            Text(status).padding()
            Button("Request") {
                provider.request(.ping) { result in
                    switch result {
                    case .success: status = "Moya Success \u{2713}"
                    case .failure(let e): status = "Error: \(e.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Moya")
    }
}

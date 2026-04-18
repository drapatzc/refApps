import SwiftUI
import AppAuth

struct AppAuthView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("AppAuth Login Flow").font(.headline)
            Text("AppAuth SDK integrated")
            Text("OIDAuthorizationRequest available")
                .font(.caption)
        }
        .navigationTitle("AppAuth")
    }
}

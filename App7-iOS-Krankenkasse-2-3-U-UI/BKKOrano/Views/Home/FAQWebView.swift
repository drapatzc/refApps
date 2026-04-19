import SwiftUI
import WebKit

/// Embedded FAQ web view loading a neutral help URL.
struct FAQWebView: View {
    var body: some View {
        FAQWebContainer(url: URL(string: "https://www.christiandrapatz.de")!)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(String(localized: "home_help_faq"))
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FAQWebContainer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}

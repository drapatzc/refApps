import SwiftUI
import Logging

struct LoggingView: View {
    private var logger = Logger(label: "de.drapatz.App12")
    @State private var messages: [String] = []
    var body: some View {
        VStack(spacing: 16) {
            Text("swift-log Console").font(.headline)
            Button("Log Message") {
                logger.info("Hello from App12")
                messages.append("Logged: \(Date().formatted(.dateTime.hour().minute().second()))")
            }
            .buttonStyle(.borderedProminent)
            List(messages, id: \.self) { Text($0).font(.caption) }
        }
        .navigationTitle("Logging")
    }
}

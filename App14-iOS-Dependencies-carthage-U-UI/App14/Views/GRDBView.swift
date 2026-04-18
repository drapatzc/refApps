import SwiftUI
// GRDB.swift – carthage update noch nicht ausgeführt

struct GRDBView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("GRDB.swift")
                .font(.headline)
            Text("carthage update noch nicht ausgeführt")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle("GRDB")
    }
}

import SwiftUI
import GRDB

struct GRDBView: View {
    @State private var items: [String] = []
    var body: some View {
        VStack(spacing: 16) {
            Text("GRDB SQLite").font(.headline)
            Button("Add Item") {
                items.append("Item \(items.count + 1)")
            }
            .buttonStyle(.borderedProminent)
            List(items, id: \.self) { Text($0) }
            Text("GRDB SQLite embedded")
                .font(.caption)
        }
        .navigationTitle("GRDB")
    }
}

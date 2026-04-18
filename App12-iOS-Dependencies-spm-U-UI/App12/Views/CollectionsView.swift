import SwiftUI
import Collections

struct CollectionsView: View {
    @State private var ordered: OrderedSet<String> = ["Apple", "Banana", "Cherry", "Apple"]
    var body: some View {
        VStack(spacing: 16) {
            Text("swift-collections").font(.headline)
            Text("OrderedSet (no duplicates): \(ordered.count) items")
            List(Array(ordered), id: \.self) { Text($0) }
            Button("Add Duplicate") {
                ordered.append("Apple")
            }
        }
        .navigationTitle("Collections")
    }
}

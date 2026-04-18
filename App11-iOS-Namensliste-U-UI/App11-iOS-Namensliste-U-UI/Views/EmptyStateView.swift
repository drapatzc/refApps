import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Keine Namen vorhanden", systemImage: "person.slash")
        } description: {
            Text("Geben Sie mit \"+\" einen neuen Namen ein")
        }
    }
}

#Preview {
    EmptyStateView()
}

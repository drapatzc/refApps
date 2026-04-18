import SwiftUI
import Defaults

extension Defaults.Keys {
    static let sampleToggle = Key<Bool>("sampleToggle", default: false)
    static let sampleText = Key<String>("sampleText", default: "Hello")
}

struct DefaultsView: View {
    @Default(.sampleToggle) var toggle
    @Default(.sampleText) var text
    var body: some View {
        Form {
            Toggle("Sample Toggle", isOn: $toggle)
            TextField("Sample Text", text: $text)
        }
        .navigationTitle("Defaults")
    }
}

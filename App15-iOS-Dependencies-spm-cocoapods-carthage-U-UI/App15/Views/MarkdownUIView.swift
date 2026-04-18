import SwiftUI
import MarkdownUI

struct MarkdownUIView: View {
    let sample = """
    # MarkdownUI Demo
    This is **bold** and *italic* text.
    - Item 1
    - Item 2
    `code snippet`
    """
    var body: some View {
        ScrollView {
            Markdown(sample)
                .padding()
        }
        .navigationTitle("MarkdownUI")
    }
}

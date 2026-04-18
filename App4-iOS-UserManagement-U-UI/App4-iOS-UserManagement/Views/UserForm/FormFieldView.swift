import SwiftUI

struct FormFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    var identifier: String = ""
    var onEditingChanged: ((Bool) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(errorMessage != nil ? .red : .secondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .accessibilityIdentifier(identifier)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            errorMessage != nil ? Color.red : Color(.systemGray4),
                            lineWidth: errorMessage != nil ? 1.5 : 1
                        )
                )
                .onChange(of: text) { _, _ in
                    // Fehler beim Tippen ausblenden
                }

            if let error = errorMessage {
                ValidationErrorView(message: error)
            }
        }
    }
}

#Preview {
    Form {
        FormFieldView(
            label: "First Name",
            placeholder: "Enter first name",
            text: .constant(""),
            errorMessage: "This field is required."
        )
        FormFieldView(
            label: "Email",
            placeholder: "Enter email",
            text: .constant("john@example.com"),
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
    }
}

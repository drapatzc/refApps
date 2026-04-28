import SwiftUI

struct SecureMessageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @FocusState private var focusedField: Field?

    enum Field { case subject, message }

    private var canSend: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        message.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.40))
                        .font(.subheadline)
                    Text("Ihre Nachricht wird Ende-zu-Ende verschlüsselt übertragen und ausschließlich von autorisierten Mitarbeitern gelesen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color(red: 0.20, green: 0.60, blue: 0.40).opacity(0.07))
            }

            Section(header: Text("Betreff")) {
                TextField("Worum geht es?", text: $subject)
                    .focused($focusedField, equals: .subject)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .message }
            }

            Section(header: Text("Ihre Nachricht")) {
                TextEditor(text: $message)
                    .focused($focusedField, equals: .message)
                    .frame(minHeight: 140)
                    .overlay(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Beschreiben Sie Ihr Anliegen ...")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }

            Section {
                Button {
                    Task {
                        focusedField = nil
                        isSubmitting = true
                        try? await Task.sleep(for: .milliseconds(800))

                        let isSuccess = Bool.random()
                        let msg = isSuccess ? "Nachricht gesendet" : "Fehler beim Senden"
                        await appState.showToast(message: msg, isSuccess: isSuccess)

                        if isSuccess {
                            subject = ""
                            message = ""
                            try? await Task.sleep(for: .milliseconds(500))
                            dismiss()
                        }
                        isSubmitting = false
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Sicher senden", systemImage: "lock.fill")
                    }
                }
                .primaryButton()
                .disabled(!canSend || isSubmitting)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
            }

            Section {
                Text("Antwortzeit: in der Regel innerhalb von 2 Werktagen.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Kontaktanfrage")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack { SecureMessageView() }
}

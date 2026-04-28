import SwiftUI
import UniformTypeIdentifiers

/// Sheet view for composing and sending a new message.
struct ComposeMessageView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var messageBody = ""
    @State private var attachments: [AttachmentItem] = []
    @State private var showFilePicker = false
    @State private var isSubmitting = false
    @FocusState private var focused: Bool

    private var canSubmit: Bool {
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !messageBody.trimmingCharacters(in: .whitespaces).isEmpty &&
        messageBody.count >= 10 &&
        attachments.count <= 3
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Betreff")) {
                    TextField("Betreffzeile", text: $subject)
                        .textContentType(.none)
                }

                Section(header: Text("Nachricht")) {
                    TextEditor(text: $messageBody)
                        .focused($focused)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if messageBody.isEmpty {
                                Text("Mindestens 10 Zeichen erforderlich...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }

                    let charCount = messageBody.count
                    HStack {
                        Spacer()
                        Text("\(charCount)/10 Zeichen")
                            .font(.caption)
                            .foregroundStyle(charCount >= 10 ? .green : .secondary)
                    }
                }

                Section(header: Text("Anhänge")) {
                    Button {
                        showFilePicker = true
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "paperclip")
                                .foregroundStyle(AppTheme.primary)
                            Text(attachments.count < 3 ? "Datei anhängen" : "Max. 3 Anhänge")
                                .foregroundStyle(attachments.count < 3 ? .primary : .secondary)
                        }
                    }
                    .disabled(attachments.count >= 3)

                    ForEach(attachments, id: \.id) { attachment in
                        HStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "doc.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(attachment.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(String(format: "%.1f KB", Double(attachment.size) / 1024))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                attachments.removeAll { $0.id == attachment.id }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    Button {
                        Task {
                            focused = false
                            isSubmitting = true
                            try? await Task.sleep(for: .milliseconds(800))

                            let isSuccess = Bool.random()
                            let attachmentText = attachments.isEmpty ? "" : " mit \(attachments.count) Anhängen"
                            let feedbackMsg = isSuccess ? "Nachricht versendet\(attachmentText)!" : "Fehler beim Versenden"

                            await appState.showToast(message: feedbackMsg, isSuccess: isSuccess)

                            if isSuccess {
                                subject = ""
                                messageBody = ""
                                attachments = []
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
                            Text("Senden")
                        }
                    }
                    .primaryButton()
                    .disabled(!canSubmit || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Neue Nachricht")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf, .jpeg, .png],
                onCompletion: handleFilePick
            )
        }
    }

    private func handleFilePick(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            _ = url.startAccessingSecurityScopedResource()
            if let data = try? Data(contentsOf: url) {
                let attachment = AttachmentItem(
                    name: url.lastPathComponent,
                    size: data.count
                )
                attachments.append(attachment)
            }
            url.stopAccessingSecurityScopedResource()

        case .failure:
            break
        }
    }
}

/// Represents an attached file in the message.
struct AttachmentItem: Identifiable {
    let id = UUID()
    let name: String
    let size: Int
}

#Preview {
    NavigationStack {
        ComposeMessageView()
            .environment(AppState())
    }
}

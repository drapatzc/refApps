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
        messageBody.trimmingCharacters(in: .whitespaces).count >= 10
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(String(localized: "compose_subject_label"))) {
                    TextField(String(localized: "compose_subject_placeholder"), text: $subject)
                        .textContentType(.none)
                }

                Section(header: Text(String(localized: "compose_message_label"))) {
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
                        Text("\(charCount)/10 " + String(localized: "common_characters"))
                            .font(.caption)
                            .foregroundStyle(charCount >= 10 ? .green : .secondary)
                    }
                }

                Section(header: Text(String(localized: "compose_attachments_title"))) {
                    Button {
                        showFilePicker = true
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "paperclip")
                                .foregroundStyle(AppTheme.primary)
                            Text(attachments.count < 3 ? String(localized: "compose_add_attachment") : String(localized: "compose_max_attachments"))
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
                            let feedbackMsg = if isSuccess {
                                if attachments.isEmpty {
                                    String(localized: "compose_sent")
                                } else {
											  String(
													format: String(localized: "compose_sent_with_attachments"),
													arguments: [attachments.count]
											  )
                                }
                            } else {
                                String(localized: "compose_send_error")
                            }

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
                            Text(String(localized: "compose_send_button"))
                        }
                    }
                    .primaryButton()
                    .disabled(!canSubmit || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "compose_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common_cancel")) {
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

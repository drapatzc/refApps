import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Sheet view for uploading a new document.
struct AddDocumentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = DocumentViewModel()
    @State private var title = ""
    @State private var selectedType: DocumentType = .sonstiges
    @State private var notes = ""
    @State private var selectedFileURL: URL? = nil
    @State private var selectedFileData: Data? = nil
    @State private var showFilePicker = false
    @State private var isSubmitting = false
    @FocusState private var focused: Bool

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedFileData != nil
    }

    private var fileSizeDisplay: String? {
        guard let fileData = selectedFileData else { return nil }
        let sizeInKB = Double(fileData.count) / 1024
        return String(format: "%.1f KB", sizeInKB)
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Dokument-Informationen")) {
                    TextField("Dokumenttitel", text: $title)
                        .textContentType(.none)

                    Picker("Dokumenttyp", selection: $selectedType) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            HStack(spacing: AppTheme.spacingS) {
                                Image(systemName: type.icon)
                                Text(type.localizedName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section(header: Text("Datei")) {
                    Button {
                        showFilePicker = true
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            Image(systemName: "doc.badge.plus")
                                .foregroundStyle(AppTheme.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedFileURL?.lastPathComponent ?? "Datei auswählen")
                                    .font(.body)
                                    .foregroundStyle(selectedFileURL != nil ? .primary : .secondary)

                                if let size = fileSizeDisplay {
                                    Text(size)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if selectedFileData != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section(header: Text("Notizen (optional)")) {
                    TextEditor(text: $notes)
                        .focused($focused)
                        .frame(minHeight: 80)
                }

                Section {
                    Button {
                        Task {
                            focused = false
                            isSubmitting = true
                            try? await Task.sleep(for: .milliseconds(800))

                            do {
                                guard let fileData = selectedFileData else { return }
                                try viewModel.add(
                                    title: title,
                                    documentType: selectedType.rawValue,
                                    fileData: fileData,
                                    notes: notes.isEmpty ? nil : notes
                                )

                                let successMsg = "Dokument '\(title)' hochgeladen"
                                await appState.showToast(message: successMsg, isSuccess: true)

                                try? await Task.sleep(for: .milliseconds(500))
                                dismiss()
                            } catch {
                                await appState.showToast(
                                    message: "Fehler beim Hochladen des Dokuments",
                                    isSuccess: false
                                )
                                isSubmitting = false
                            }
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Dokument hochladen")
                        }
                    }
                    .primaryButton()
                    .disabled(!canSubmit || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Neues Dokument")
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
        .task {
            await viewModel.setup(context: modelContext)
        }
    }

    private func handleFilePick(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            selectedFileURL = url
            _ = url.startAccessingSecurityScopedResource()
            if let data = try? Data(contentsOf: url) {
                selectedFileData = data
            }
            url.stopAccessingSecurityScopedResource()

        case .failure:
            selectedFileURL = nil
            selectedFileData = nil
        }
    }
}

#Preview {
    NavigationStack {
        AddDocumentView()
            .environment(\.modelContext, ModelContext(ModelContainer.preview))
            .environment(AppState())
    }
}

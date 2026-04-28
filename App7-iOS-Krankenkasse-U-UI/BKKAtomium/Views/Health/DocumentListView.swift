import SwiftUI
import SwiftData

/// View for managing insurance documents with upload and delete capabilities.
struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var viewModel = DocumentViewModel()
    @State private var showAddSheet = false

    var body: some View {
        List {
            if viewModel.documents.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text(String(localized: "health_documents_empty_title"))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(String(localized: "health_documents_empty_subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingL)
                    .listRowBackground(Color.clear)
                }
            } else {
                Section(header: Text(String(localized: "health_documents_title"))) {
                    ForEach(viewModel.documents.sorted { $0.uploadDate > $1.uploadDate }) { document in
                        DocumentRow(document: document)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task {
                                        try? viewModel.delete(document)
                                    }
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                ShareLink(
                                    item: document.title,
                                    subject: Text("Dokument"),
                                    message: Text("Typ: \(document.documentType)")
                                ) {
                                    Label("Teilen", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                    }
                }

                Section(header: Text(String(localized: "health_documents_storage_title"))) {
                    let totalSize = viewModel.documents.map(\.fileData.count).reduce(0, +)
                    let sizeInMB = Double(totalSize) / (1024 * 1024)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "health_documents_storage_total"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.2f MB", sizeInMB))
                                .font(.headline)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(localized: "health_documents_storage_count"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(viewModel.documents.count)")
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "health_documents_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddDocumentView()
        }
        .task {
            await viewModel.setup(context: modelContext)
        }
    }
}

/// A single document row showing title, type, and date.
private struct DocumentRow: View {
    let document: InsuranceDocument

    var documentType: DocumentType {
        DocumentType(rawValue: document.documentType) ?? .sonstiges
    }

    var fileSizeInKB: Double {
        Double(document.fileData.count) / 1024
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: documentType.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(document.uploadDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(documentType.localizedName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(String(format: "%.0f KB", fileSizeInKB))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        DocumentListView()
            .environment(\.modelContext, ModelContext(ModelContainer.preview))
            .environment(AppState())
    }
}

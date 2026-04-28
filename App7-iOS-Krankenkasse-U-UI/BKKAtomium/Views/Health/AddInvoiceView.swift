import SwiftUI
import SwiftData

/// Sheet view for adding a new invoice.
struct AddInvoiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = InvoiceViewModel()
    @State private var selectedDate = Date()
    @State private var provider = ""
    @State private var amount = ""
    @State private var selectedCategory: InvoiceCategory = .arzt
    @State private var selectedStatus: InvoiceStatus = .offen
    @State private var description = ""
    @State private var isSubmitting = false
    @FocusState private var focused: Bool

    private var canSubmit: Bool {
        !provider.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount.replacingOccurrences(of: ",", with: ".")) != nil
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Grunddaten")) {
                    DatePicker(
                        "Datum",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )

                    TextField("Anbieter (z.B. Dr. Schmidt)", text: $provider)
                        .textContentType(.none)

                    HStack(spacing: 8) {
                        TextField("Betrag in €", text: $amount)
                            .keyboardType(.decimalPad)

                        if !amount.isEmpty && Double(amount.replacingOccurrences(of: ",", with: ".")) != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else if !amount.isEmpty {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(InvoiceCategory.allCases, id: \.self) { category in
                            HStack(spacing: AppTheme.spacingS) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.primary)
                                Text(category.localizedName)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section(header: Text("Status")) {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(InvoiceStatus.allCases, id: \.self) { status in
                            HStack(spacing: AppTheme.spacingS) {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(status.color)
                                Text(status.localizedName)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section(header: Text("Beschreibung (optional)")) {
                    TextEditor(text: $description)
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
                                try viewModel.add(
                                    date: selectedDate,
                                    amount: Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0,
                                    provider: provider,
                                    category: selectedCategory.rawValue,
                                    status: selectedStatus.rawValue,
                                    description: description.isEmpty ? nil : description
                                )

                                let successMsg = "Rechnung von \(provider) hinzugefügt"
                                await appState.showToast(message: successMsg, isSuccess: true)

                                try? await Task.sleep(for: .milliseconds(500))
                                dismiss()
                            } catch {
                                await appState.showToast(
                                    message: "Fehler beim Hinzufügen der Rechnung",
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
                            Text("Rechnung erstellen")
                        }
                    }
                    .primaryButton()
                    .disabled(!canSubmit || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppTheme.spacingM, bottom: 4, trailing: AppTheme.spacingM))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Neue Rechnung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.setup(context: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        AddInvoiceView()
            .environment(\.modelContext, ModelContext(ModelContainer.preview))
            .environment(AppState())
    }
}
